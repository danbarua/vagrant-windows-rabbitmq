REM This is the place to configure RabbitMQ Windows Service and plugin configuration
REM Calling these batch files from Powershell seems to hang the Vagrant shell provisioner

cmd /c rabbitmq-service install

cmd /c rabbitmq-plugins enable rabbitmq_management

cmd /c rabbitmq-plugins enable rabbitmq_federation

cmd /c rabbitmq-plugins enable rabbitmq_federation_management

cmd /c rabbitmq-plugins enable rabbitmq_shovel

cmd /c rabbitmq-plugins enable rabbitmq_shovel_management

cmd /c  rabbitmq-service start