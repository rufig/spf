# $Id$
#
# Update SPF website manually (as cron is disabled at sf.net)
# Usage:
#   ./update.sh -l <sfusername> 

ssh $* shell.sf.net 'cd /home/groups/s/sp/spf/spf/tools/website && cvs up -d -P -C && make'
