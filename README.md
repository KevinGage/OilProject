# OilProject

This project is intended to monitor oil prices and notify you when they drop below a defined price.

To install on debian/ubuntu/raspbian
  1.  git clone https://github.com/KevinGage/OilProject.git
  2.  cd OilProject
  3.  sudo ./linux_installer.sh
  4.  complete setup wizard
  5.  when completed you can delete the OilProject folder and all of its contents.  The actual program is setup to run in /opt/OilPriceChecker.  The schedule is a cron job named /etc/cron.d/OilPriceChecker
