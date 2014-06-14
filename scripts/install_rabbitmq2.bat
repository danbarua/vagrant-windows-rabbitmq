cmd /c rabbitmq-service install

cmd /c rabbitmq-plugins enable rabbitmq_management

cmd /c rabbitmq-plugins enable rabbitmq_federation

cmd /c rabbitmq-plugins enable rabbitmq_federation_management

cmd /c rabbitmq-plugins enable rabbitmq_shovel

cmd /c rabbitmq-plugins enable rabbitmq_shovel_management

cmd /c  rabbitmq-service start