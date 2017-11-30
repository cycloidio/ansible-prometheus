require 'spec_helper'
data_file = './data.rb'
require data_file if File.file? data_file

describe 'Prometheus' do

  %w(/srv /srv/alertmanager ).each do |dir|
    describe file(dir) do
      it { should be_directory }
      it { should be_owned_by('root') }
    end
  end

  %w(/srv/prometheus-data ).each do |dir|
    describe file(dir) do
      it { should be_directory }
      it { should be_owned_by('nobody') }
    end
  end

  describe file('/srv/prometheus-data/prometheus.yml') do

    prometheus_content = "global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    test: test
rule_files: 
- /prometheus-data/alert.rules
scrape_configs:
-   job_name: prometheus
    scrape_interval: 10s
    scrape_timeout: 10s
    static_configs:
    -   targets:
        - localhost:9090
-   job_name: node_exporter
    scrape_interval: 5s
    static_configs:
    -   targets:
        - 10.0.2.15:9100
alerting:
  alertmanagers:
  -   scheme: http
      static_configs:
      -   targets:"

    it { should be_file }
    it { should contain(prometheus_content) }
  end

  describe file('/srv/prometheus-data/alert.rules') do
    it { should be_file }
    its(:content) { should match /alert: InstanceDown/ }
  end

  describe file('/srv/alertmanager/alertmanager.yml') do

    alertmanager_content = 'route:
    group_by:
    - cluster
    - alertname
    - host
    group_interval: 2m
    group_wait: 30s
    receiver: webhook
    repeat_interval: 10m
    routes:
    -   match:
            severity: warning
        receiver: webhook
    -   match:
            severity: critical
        receiver: webhook
templates:
- /alertmanager/template/*.tmpl

inhibit_rules:
-   equal:
    - alertname
    - host
    source_match:
        severity: critical
    target_match:
        severity: warning

receivers:
-   name: webhook
    webhook_configs:
    -   url: http://127.0.0.1:5001/'

    it { should be_file }
    it { should contain(alertmanager_content) }
  end

  describe docker_image('prom/prometheus:latest') do
    its(['Architecture']) { should eq 'amd64' }
    it { should exist }
  end

  describe docker_image('prom/alertmanager:latest') do
    its(['Architecture']) { should eq 'amd64' }
    it { should exist }
  end

  describe docker_container('prometheus') do
     it { should exist }
     it { should be_running }
     it { should have_volume('/prometheus-data','/srv/prometheus-data') }
  end

  describe docker_container('alertmanager') do
     it { should exist }
     it { should be_running }
     it { should have_volume('/alertmanager','/srv/alertmanager') }
  end

  describe command("curl -d '[{\"labels\": {\"Alertname\": \"ansible-test\"}}]' http://localhost:9093/api/v1/alerts") do
    its(:stdout) { should match '{"status":"success"}' }
    its(:exit_status) { should eq 0 }
  end

  describe command("docker logs prometheus") do
    its(:stdout) { should_not match /level=error/ }
  end

  describe command("docker logs alertmanager") do
    its(:stdout) { should_not match /level=error/ }
  end
end
