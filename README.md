#CloudPassage Scan all Servers Example

Version: *1.0*
<br />
Author: *Eric Hoffmann* - *ehoffmann@cloudpassage.com*

Users can use the provided example script to initiate a scan against all active servers. It uses the Halo API to launch the scan, using the cmdline option to specify which type of scan. Supported types are:
* SVA - Software Vulnerability Assessement
* CSM - Configuration Security Monitoring
* SAM - Server Account Management
* FIM - File Integrity Monitoring

##Requirements and Dependencies

To run, this script requires

* Ruby installed on the host that runs the script
* Ruby gems: oauth2, rest-client, json
* A read-only Halo API key/secret stored in a yaml file
* The location of the yaml file set as a ENV variable

##List of Files

* **scan_all_servers.rb**  - Ruby script which leverages the Halo API to initiate a server scan 
* **README.md**  -  This ReadMe file
* **Gemfile** - Gemfile to install ruby requirements
* **LICENSE.txt**  -  License from CloudPassage

##Usage

1. Copy a read-only Halo API key/secret from the Halo Portal into a "dot" file ie ~/.halo
2. Set the location of the api-key file as a ENV variable called HALO_API_KEY_FILE
3. Run bundler to install the ruby requirements: bundle install
4. Execute the script

The format of ~/.halo
```
halo:
  key_id : XXXXXXXX
  secret_key : XXXXXXXXXXXXXXXXXXXXXXXXXXX
```

The additional variable in your ~/.bash_profile
```
HALO_API_KEY_FILE="/home/<your username>/.halo"
export HALO_API_KEY_FILE
```

How to excute the script
```
ruby scan_all_servers.rb --sva
[INFO] successfully launched sva against docker-ubuntu-ec2:52.211.9.65
[INFO] successfully launched sva against docker-ubuntu1404-ec2:52.212.2.159
...
```
