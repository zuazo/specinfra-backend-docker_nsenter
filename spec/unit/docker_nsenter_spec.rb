# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@zuazo.org>)
# Copyright:: Copyright (c) 2015 Xabier de Zuazo
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Specinfra::Backend::DockerNsenter do
  subject { DisabledDockerNsenter.new }
  let(:pid) { '4142' }
  let(:container_json) { { 'State' => { 'Pid' => pid } } }
  let(:container) { double('Docker::Container', json: container_json) }
  before { subject.instance_variable_set(:@container, container) }

  context '#nsenter_command' do
    before { allow(subject).to receive(:sudo?).and_return(false) }

    it 'returns the correct nsenter command' do
      cmd =
        [
          'nsenter', '-t', pid, '-m', '-u', '-i', '-n', '-p', 'sh', '-c',
          'echo Hello World'
        ]
      expect(subject.send(:nsenter_command, 'echo Hello World')).to eq cmd
    end
  end

  context '#nsenter_result_assert' do
    it 'does not raise an exception if ended successfully' do
      expect { subject.send(:nsenter_result_assert, 'stderr', 0) }
        .to_not raise_error
    end

    it 'does not raise an exception for normal errors' do
      expect { subject.send(:nsenter_result_assert, 'stderr', 1) }
        .to_not raise_error
    end

    it 'raises an exception for nsenter errors' do
      stderr = 'nsenter: Error'
      expect { subject.send(:nsenter_result_assert, stderr, 1) }
        .to raise_error(
          Specinfra::Backend::DockerNsenter::NsenterError,
          Regexp.new(Regexp.escape(stderr))
        )
    end

    it 'raises an exception for sudo errors' do
      stderr = 'sudo: Error'
      expect { subject.send(:nsenter_result_assert, stderr, 1) }
        .to raise_error(
          Specinfra::Backend::DockerNsenter::NsenterError,
          Regexp.new(Regexp.escape(stderr))
        )
    end
  end

  context '#docker_run!' do
    let(:cmd) { 'uname -a' }
    let(:stdout) { 'stdout' }
    let(:stderr) { 'stderr' }
    let(:exit_status) { 25 }
    let(:nsenter_command) { %w(nsenter command) }
    before do
      allow(subject).to receive(:nsenter_command).and_return(nsenter_command)
      allow(subject).to receive(:shell_command!)
        .and_return([stdout, stderr, exit_status])
      allow(subject).to receive(:nsenter_result_assert)
    end

    it 'calls #nsenter_command' do
      expect(subject).to receive(:nsenter_command).with(cmd).once
        .and_return(nsenter_command)
      subject.send(:docker_run!, cmd)
    end

    it 'calls #shell_command!' do
      expect(subject).to receive(:shell_command!).with(nsenter_command, {})
        .once.and_return(nsenter_command)
      subject.send(:docker_run!, cmd)
    end

    it 'calls #shell_command! with options' do
      opts = { key1: 'val1' }
      expect(subject).to receive(:shell_command!).with(nsenter_command, opts)
        .once.and_return(nsenter_command)
      subject.send(:docker_run!, cmd, opts)
    end

    it 'calls #nsenter_result_assert' do
      expect(subject).to receive(:nsenter_result_assert)
        .with(stderr, exit_status).once
      subject.send(:docker_run!, cmd)
    end

    it 'calls #rspec_example_metadata' do
      expect(subject).to receive(:rspec_example_metadata)
        .with(cmd, stdout, stderr).once
      subject.send(:docker_run!, cmd)
    end

    it 'returns a CommandResult' do
      expect(subject.send(:docker_run!, cmd)).to be_a CommandResult
    end

    it 'returns stdout result' do
      expect(subject.send(:docker_run!, cmd).stdout).to eq stdout
    end

    it 'returns stderr result' do
      expect(subject.send(:docker_run!, cmd).stderr).to eq stderr
    end

    it 'returns exit status result' do
      expect(subject.send(:docker_run!, cmd).exit_status).to eq exit_status
    end

    it 'reraises NsenterError exceptions' do
      error_class = Specinfra::Backend::DockerNsenter::NsenterError
      allow(subject).to receive(:nsenter_result_assert).and_raise(error_class)
      expect { subject.send(:docker_run!, cmd) }.to raise_error(error_class)
    end

    context 'with non-NsenterError exceptions' do
      let(:exception) { StandardError.new('EOW') }
      let(:erroneous_result) { 'erroneous result' }
      before do
        allow(subject).to receive(:nsenter_result_assert).and_raise(exception)
        allow(subject).to receive(:erroneous_result)
          .and_return(erroneous_result)
        allow(container).to receive(:kill)
      end

      it 'kills the container' do
        expect(container).to receive(:kill).once.with(no_args)
        subject.send(:docker_run!, cmd)
      end

      it 'calls #erroneous_result' do
        expect(subject).to receive(:erroneous_result).once
          .with(cmd, exception, stdout, stderr, exit_status)
        subject.send(:docker_run!, cmd)
      end

      it 'returns #erroneous_result result' do
        expect(subject.send(:docker_run!, cmd)).to eq(erroneous_result)
      end
    end
  end
end
