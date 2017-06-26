# nsupdate.info-updater

nsupdate.info is a free and open dynamic DNS (DDNS) service, available
at https://www.nsupdate.info/

nsupdate.info-updater is used to update IP addresses in nsupdate.info.
nsupdate.info system does not like to receive several conections in a
short time. As an example, a cron task to send your current IP to the
site every 4 hours will block your account and you will need to access
the system to unblock.

nsupdate.info-updater verify if the IP address was changed before send
it to the system, avoiding a block action from the system.

## How to use

* Copy the conf file to /etc.
* Create the /var/lib/nsupdate.info-updater/ directory.
* Execute the script: ./update.info-updater.sh to test.
* Use crontab to call the script each 5 or 10 minutes.

## Dependencies

This program depends of the bash and of the commands curl, dig and logger.

## License

This program is under BSD-3-Clause.
