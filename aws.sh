#!/bin/bash
# need AWS Command line installed.  tested on osx

for i in {0..0}
do
   echo "Launching cluster cdf-nyc-workshop00$i ..."
   instance_id=`aws ec2 run-instances --image-id ami-7 --count 1 --instance-type m4.xlarge --key-name tspanntest --security-group-ids sg-04a80a2ea50b252c1 --subnet-id subnet-080996dabec44f591 | grep InstanceId | awk -F \" '{print $4}'`
   echo "Instance ID $instance_id"
   aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=NYCCDFWorkshop0$i
   aws ec2 create-tags --resources $instance_id --tags Key=project,Value=NYCCDFWorkshop
   aws ec2 create-tags --resources $instance_id --tags Key=assigned_hostname,Value=cdf-nyc-workshop00$i
   aws ec2 create-tags --resources $instance_id --tags Key=instance-name,Value=cdf-nyc-workshop00$i
   aws ec2 create-tags --resources $instance_id --tags Key=owner,Value=tspann
   aws ec2 create-tags --resources $instance_id --tags Key=enddate,Value=07262019
   aws ec2 create-tags --resources $instance_id --tags Key=weekend-shutdown,Value=TRUE
   echo "Tags all added."
   sleep 5 
   dns=`aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].PublicDnsName' --output text`
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo yum update -y'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo yum install xz-devel -y'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo yum install -y python34u python34u-libs python34u-devel python34u-pip'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo pip3.4 install --upgrade pip'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'pip3 install --upgrade pip'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo pip3.4 install requests pyopenssl'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo pip3.4 install https://github.com/Chaffelson/nipyapi/archive/efm.zip'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'sudo pip3.4 install asyncio'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'pip3.4 install psutil'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'pip3.4 install vaderSentiment'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'python3 -c "import site; print(site.getsitepackages())"'
   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'python3  -c "import sys; print(sys.executable)"'
# MiNiFi CPP may need pythonpath
#   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'export PYTHONPATH=/bin/lib64/python3.4'
#   ssh -oStrictHostKeyChecking=no -t  -i cdf.pem centos@$dns 'export PYTHONHOME=/bin'
   curl -d '{"name":"efm"}'  -H "Content-Type: application/json" -X POST http://$dns:61080/nifi-registry-api/buckets/
   curl -u admin:StrongPassword -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Kafka via REST"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://$dns:8080/api/v1/clusters/hdf/services/KAFKA
   echo "Instance complete.i `date`"
done
