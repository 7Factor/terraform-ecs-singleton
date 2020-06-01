require 'awspec'
require 'hcl/checker'

TFVARS = HCL::Checker.parse(File.open('testing.tfvars').read())
ENVVARS = eval(ENV['KITCHEN_KITCHEN_TERRAFORM_OUTPUTS'])

describe ecs_service("#{TFVARS['app_name']}-svc"), cluster: TFVARS['cluster_name'] do
  it { should exist }
  it { should be_active }

  it 'should have no load balancers' do
    load_balancers = subject.load_balancers.map {|load_balancer| load_balancer}

    expect(load_balancers.length).to eq 0
  end

  its(:desired_count) { should eq TFVARS['desired_task_count']}
  its(:launch_type) { should eq TFVARS['launch_type']}
  its(:task_definition) { should eq ENVVARS[:task_definition_arn][:value]}
  its(:status) { should eq 'ACTIVE'}
end