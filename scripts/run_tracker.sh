#!/bin/bash -xe
# run_tracker.sh ---
#
# Filename: run_tracker.sh
# Description:
# Author: Elric Milon
# Maintainer:
# Created: Fri Jun 14 12:44:06 2013 (+0200)

# Commentary:
#
# %*% Starts a dispersy tracker.
#
#

# Change Log:
#
#
#
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 51 Franklin Street, Fifth
# Floor, Boston, MA 02110-1301, USA.
#
#

# Code:

# find_free_port ()
# {
#     while true; do
#         TRACKER_PORT=$[ ( $RANDOM % 65535 )  + 1 ]
#         lsof -iudp -n -P | awk '{ print $9 }' | grep -q "^*:$TRACKER_PORT$" || ( echo "No one is listening in $TRACKER_PORT" >&2 ; break )
#     done
# }
#
#Find an unused port
#find_free_port
#echo "TRACKER_PORT=$TRACKER_PORT" >> experiment_run.conf

cd $PROJECT_DIR

if [ -e tribler ]; then
    cd tribler
    MODULEPATH=Tribler.dispersy.tool.tracker
else
    MODULEPATH=dispersy.tool.tracker
fi

if [ -z "$HEAD_HOST" ]; then
    HEAD_HOST=$(hostname)
fi

# @CONF_OPTION TRACKER_PORT: Port in which the Dispersy tracker should be listening on.
echo $HEAD_HOST $TRACKER_PORT > bootstraptribler.txt

python -O -c "from $MODULEPATH import main; main()" --port $TRACKER_PORT 2>&1 > "$OUTPUT_DIR/tracker_out.log"

#
# run_tracker.sh ends here
