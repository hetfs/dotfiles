# HETFS LTD. - Code for a Brighter Future
# https://github.com/hetfs/dotfiles
#
# Ansible Strategy Plugin: bootstrap_priority
#
# Purpose:
#   - Forces Windows hosts to always run bootstrap.yml first.
#   - Ensures proper WinRM reconnection after bootstrap.
#   - Falls back to linear execution for all other hosts.

from ansible.plugins.strategy.linear import StrategyModule as LinearStrategy
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.playbook.task_include import TaskInclude
from ansible.playbook.block import Block
from ansible.errors import AnsibleError

DOCUMENTATION = r'''
strategy: bootstrap_priority
short_description: Run Windows bootstrap before regular tasks
description:
  - Ensures Windows hosts execute tasks/bootstrap.yml before all other tasks.
  - Re-establishes WinRM after bootstrap completes.
  - Uses linear strategy as the base behavior.
author: HETFS LTD.
'''

class StrategyModule(LinearStrategy):

    def __init__(self, tqm: TaskQueueManager):
        super().__init__(tqm)
        self.bootstrap_done = {}

    def _is_windows(self, host):
        # Detect based on ansible_os_family
        vars = self._variable_manager.get_vars(host=host)
        return vars.get("ansible_os_family", "").lower() == "windows"

    def _queue_bootstrap(self, host, play):
        loader = self._loader
        basedir = play.get_basedir()

        bootstrap_path = f"{basedir}/tasks/bootstrap.yml"

        try:
            include_task = TaskInclude.load(
                data=dict(include=bootstrap_path),
                play=play,
                loader=loader,
                variable_manager=self._variable_manager
            )
        except Exception as e:
            raise AnsibleError(f"Failed to load bootstrap.yml: {str(e)}")

        return Block(block=[include_task], loader=loader, variable_manager=self._variable_manager)

    def add_tasks(self, hosts, task, play, iterator):
        new_tasks = []

        for host in hosts:
            name = host.get_name()

            # Skip non-Windows hosts
            if not self._is_windows(host):
                continue

            # If bootstrap already ran for this host, skip
            if self.bootstrap_done.get(name):
                continue

            # Queue bootstrap
            block = self._queue_bootstrap(host, play)
            iterator.add_tasks(host, block.block)
            self.bootstrap_done[name] = True

            # Force reconnection of WinRM session
            try:
                host.close_shell()
            except Exception:
                pass

        return super().add_tasks(hosts, task, play, iterator)
