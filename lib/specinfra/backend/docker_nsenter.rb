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

require 'specinfra/backend/docker'
require 'specinfra/backend/docker_lxc'
require 'specinfra/backend/docker_nsenter/exceptions'

# Command Execution Framework for Serverspec, Itamae and so on.
module Specinfra
  # Specinfra backend types.
  module Backend
    # Specinfra and Serverspec backend for Docker `nsenter` execution driver.
    class DockerNsenter < DockerLxc
      protected

      # Generates `nsenter` command to run.
      #
      # @param cmd [String] the commands to run inside docker.
      # @return [Array] the command to run as unescaped array.
      def nsenter_command(cmd)
        pid = @container.json['State']['Pid']
        ['nsenter', '-t', pid, '-m', '-u', '-i', '-n', '-p', 'sh', '-c', cmd]
      end

      # Parses `nsenter` command output and raises an exception if it is an
      # error from the `nsenter` program.
      #
      # @param stderr [String] command *stderr* output.
      # @param exit_status [Fixnum] command exit status.
      # @return nil
      def nsenter_result_assert(stderr, exit_status)
        return if exit_status == 0
        return if stderr.match(/\A(nsenter|sudo): /).nil?
        fail NsenterError, stderr
      end

      # Runs a command inside a Docker container.
      #
      # @param cmd [String] the command to run.
      # @param opts [Hash] options to pass to {Open3.popen3}.
      # @return [Specinfra::CommandResult] the result.
      def docker_run!(cmd, opts = {})
        stdout, stderr, status = shell_command!(nsenter_command(cmd), opts)
        nsenter_result_assert(stderr, status)
        rspec_example_metadata(cmd, stdout, stderr)
        CommandResult.new(stdout: stdout, stderr: stderr, exit_status: status)
      rescue NsenterError
        raise
      rescue => e
        @container.kill
        erroneous_result(cmd, e, stdout, stderr, status)
      end
    end
  end
end
