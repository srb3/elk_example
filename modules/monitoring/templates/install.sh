#!/bin/bash
set -exu

WORKING_DIR=${tmp_path}

exec > $${WORKING_DIR}/elk_install.log 2>&1

function yum_install() {
  if ! rpm -q $1; then
    yum install -y $1
  fi
}

function setup_yum_repo() {
  if [ ! -f /etc/yum.repos.d/$${1} ]; then
    cat << EOF >> /etc/yum.repos.d/$${1}
$2
EOF
  fi
  yum makecache -y
}

function kibana_config() {
  if ! grep "^server.host: \"0\.0\.0\.0\"" /etc/kibana/kibana.yml; then
    cat << EOF > /etc/kibana/kibana.yml
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOF
  fi
}

function logstash_config() {

  if [[ ! -d /var/log/data-feed ]]; then
    mkdir -p /var/log/data-feed
  fi

  chown -R logstash:logstash /var/log/data-feed


  if [[ ! -d /var/log/logstash ]]; then
    mkdir -p /var/log/logstash
  fi

  chown -R logstash:logstash /var/log/logstash

  if [ ! -f /etc/logstash/conf.d/data-feed-logstash.conf ]; then
    cat << EOF > /etc/logstash/conf.d/data-feed-logstash.conf
input {
  http {
    host => "0.0.0.0"
    port => 8080
    additional_codecs => {"application/json" => "json_lines" }
  }
}
filter {
  mutate {
    remove_field => [ "message", "headers", "@version", "host" ]
  }
  ruby {
    path => "/opt/logstash/scripts/t_parse.rb"
  }
}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "data-feed-%%{+dd.MM.YYYY}"
  }
  file {
    path => "/var/log/data-feed/data-feed.log"
    write_behavior => "overwrite"
  }
  stdout { 
    codec => rubydebug 
  }
}
EOF
  fi

  if [ ! -f /opt/logstash/scripts ]; then
    mkdir -p /opt/logstash/scripts
  fi
  chown -R logstash:logstash /opt/logstash/scripts

  if [ ! -f /opt/logstash/scripts/t_parse.rb ]; then
    cat << EOF > /opt/logstash/scripts/t_parse.rb
def status(h, s)
  h.select {|x| x['status'] == s }.length
end
def filter(event)
  report = event.get('report')
  profiles = 0
  failed_profiles = 0
  passed_profiles = 0
  controls = 0
  passed_controls = 0
  failed_controls = 0
  results = 0
  passed_results = 0
  failed_results = 0
  result_hash = {}
  profiles += report['profiles'].length
  passed_profiles = status(report['profiles'], 'passed')
  failed_profiles = status(report['profiles'], 'failed')
  report['profiles'].each do |p|
    controls += p['controls'].length
    p['controls'].each do |c|
      pn = p['name']
      id = c['id']
      key = "#{pn}_#{id}"
      result_hash[key] = {}
      if c['results'].nil?
        result_hash[key]['passed_results'] = 0
        result_hash[key]['failed_results'] = 0
        result_hash[key]['results'] = 0
      else
        result_hash[key]['passed_results'] = status(c['results'],'passed')
        result_hash[key]['failed_results'] = status(c['results'],'failed')
        result_hash[key]['results'] = c['results'].length
        results += c['results'].length
        passed_results += status(c['results'], 'passed')
        failed_results += status(c['results'], 'failed')
      end
    end
  end
  case result_hash.select { |_k, v| v['results'] > 0 && v['failed_results'] > 0 }.empty?
  when true
    passed_controls += 1
  when false
    failed_controls += 1
  end
  event.set('profiles', profiles)
  event.set('failed_profiles', failed_profiles)
  event.set('passed_profiles', passed_profiles)
  event.set('controls', controls)
  event.set('failed_controls', failed_controls)
  event.set('passed_controls', passed_controls)
  event.set('results', results)
  event.set('passed_results', passed_results)
  event.set('failed_results', failed_results)
  event.set('summary', result_hash)
  [event]
end 
EOF
  fi
}

function logstash_jvm() {
  if ! grep tf_written /etc/logstash/jvm.options; then
    cat << EOF > /etc/logstash/jvm.options
# tf_written
-Xms${logstash_heap}g
-Xmx${logstash_heap}g
-XX:+UseConcMarkSweepGC
-XX:CMSInitiatingOccupancyFraction=75
-XX:+UseCMSInitiatingOccupancyOnly
-Djava.awt.headless=true
-Dfile.encoding=UTF-8
-Djruby.compile.invokedynamic=true
-Djruby.jit.threshold=0
-Djruby.regexp.interruptible=true
-XX:+HeapDumpOnOutOfMemoryError
-Djava.security.egd=file:/dev/urandom
-Dlog4j2.isThreadContextMapInheritable=true
EOF
  fi
}
function elasticsearch_jvm() {
  if ! grep tf_written /etc/elasticsearch/jvm.options; then
    cat << EOF > /etc/elasticsearch/jvm.options
# tf_written
-Xms${elasticsearch_heap}g
-Xmx${elasticsearch_heap}g
8-13:-XX:+UseConcMarkSweepGC
8-13:-XX:CMSInitiatingOccupancyFraction=75
8-13:-XX:+UseCMSInitiatingOccupancyOnly
14-:-XX:+UseG1GC
14-:-XX:G1ReservePercent=25
14-:-XX:InitiatingHeapOccupancyPercent=30
-Djava.io.tmpdir=\$${ES_TMPDIR}
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=/var/lib/elasticsearch
-XX:ErrorFile=/var/log/elasticsearch/hs_err_pid%p.log
8:-XX:+PrintGCDetails
8:-XX:+PrintGCDateStamps
8:-XX:+PrintTenuringDistribution
8:-XX:+PrintGCApplicationStoppedTime
8:-Xloggc:/var/log/elasticsearch/gc.log
8:-XX:+UseGCLogFileRotation
8:-XX:NumberOfGCLogFiles=32
8:-XX:GCLogFileSize=64m
9-:-Xlog:gc*,gc+age=trace,safepoint:file=/var/log/elasticsearch/gc.log:utctime,pid,tags:filecount=32,filesize=64m
EOF
  fi
}

%{ for k,v in yum_repos }
  setup_yum_repo "${k}" "${v}"
%{ endfor }

%{ for p in yum_packages }
  yum_install ${p}
%{ endfor }

yum_install elasticsearch
yum_install logstash
yum_install kibana

logstash_config
kibana_config
logstash_jvm
elasticsearch_jvm

systemctl daemon-reload
systemctl enable elasticsearch --now
systemctl enable logstash --now
systemctl enable kibana --now
