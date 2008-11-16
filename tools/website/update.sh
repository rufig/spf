# $Id$
#
# Update SPF website manually (as cron is disabled at sf.net)
# Usage:
#   ./update.sh <sfusername> 

host=$1,spf@shell.sf.net

ssh $host create
ssh $host 'cd /home/groups/s/sp/spf/spf/tools/website && cvs up -d -P -C && make'
ssh $host shutdown
