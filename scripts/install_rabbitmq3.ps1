Write-Host "Copying .erlang.cookie"
Copy-Item C:\Windows\.erlang.cookie C:\Users\vagrant\.erlang.cookie -Force

Write-Host "Enabling Firewall ports"
New-NetFirewallRule -DisplayName "Allow Port 5672 (AMQP)" -Direction Inbound -LocalPort 5672 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Port 5671 (AMQP over SSL)" -Direction Inbound -LocalPort 5672 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Port 15672 (RabbitMQ Management)" -Direction Inbound -LocalPort 15672 -Protocol TCP -Action Allow