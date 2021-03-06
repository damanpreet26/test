#!/bin/bash

#################################################################
# Settings.py file changing script                              #
#                                                               #
#                                                               #
#  run in terminal, use ./auto.sh                               #
#                                                               #
# Made By : Damanpreet Singh (DEMON)                            #
# http://damanpreet.co.cc/                                      #
#                                                               #
#                                                               #
# created : 4-10-2012                                           #
# last update : 30-11-2012                                      #
# VER=1.4                                                       #
#                                                               #
#################################################################

# this script works only for python 2.7

backup()
{
  sudo cp /etc/apache2/httpd.conf Automation/other_files/   #copies httpd.conf file in Automation/other_files/ folder
}


media()
{
  sudo cp -r Automation/other_files/media/ /usr/local/lib/python2.7/dist-packages/django/contrib/admin/
  sudo chmod -R 777 /usr/local/lib/python2.7/dist-packages/django/contrib/admin/media/
}

run()  # the function 
{
  echo ""
  echo "######################################################"
  echo "#                                                    #"
  echo "#    INSTALLING---TCC-Automation software---         #"
  echo "#                                                    #"
  echo "######################################################"
  echo ""
  #################################################################
  #
  # arrays with their values.
  #
  #################################################################

  file=Automation/settings.py

  array=("enter the email address :")
  array1=("email_add")
  array2=("37")

  #################################################################
  #
  #  asking user to input the mysql username
  #
  #################################################################

  a=1
  while [ $a -ne 2 ]
      do
         {

# inputs database name from the user
            read -p "enter mysql username :" db_user
            read -p "enter mysql password :" db_password
            RESULT=`mysql --user="$db_user" --password="$db_password" --skip-column-names -e "SHOW DATABASES LIKE 'mysql'"` 2> /dev/null
            if [ $RESULT ]; then
               echo ""
               echo "Username and password match"
               a=2
               break
            else
               echo "" 
               echo "Username and password doesn't match"
               echo "re-enter the details"
               echo ""

            fi
        }
  done
  sed -i "16 s/db_user/$db_user/" $file
  sed -i "17 s/db_password/$db_password/" $file
  ##################################################################
  #
  # length of the array
  #
  ##################################################################


  len=${#array[*]}
  i=0
  while [ $i -lt $len ]; do
     read -p "${array[$i]}" ${array1[$i]}                           #this reads input from the user
     sed -i "${array2[$i]} s/${array1[$i]}/${!array1[$i]}/" $file   #uses sed command to replace word from file to be replaced by user inputs
     let i++
  done                                                    #end of for loop
        
# this part checks if database name entered is created before or not.        
  a=1
  while [ $a -ne 2 ]
     do
      {

# inputs database name from the user
         read -p "enter database name you want to create :" db_name

#checks the existance of database
         RESULT=`mysql --user="$db_user" --password="$db_password" --skip-column-names -e "SHOW DATABASES LIKE '$db_name'"`
         if [ $RESULT ]; then
            echo "The Database exist, choose another name for database."
         else
            a=2
            break
         fi
      }
  done    
  sed -i "15 s/db_name/$db_name/" $file
  #cat Automation/settings.py                       #reads file in terminal

  #################################################################################
  #
  # here the username automatically gets input from the system
  #
  #################################################################################

  NAME=$(who am i | awk '{print $1}')
  sed -i "111 s/user_name/$NAME/" $file
  echo "the username is $NAME"


  ######################################################################
  #
  # Determining the path of the script and making necessary changes 
  #
  ######################################################################


  path=$PWD     #this passes PWD value in path
  echo "Successfully downloading the software at-$path"
  echo ""
  sed -i "s#mPath#"$path"#g" Automation/other_files/hhtp_cont   
  sed -i "s#mPath#"$path"#g" Automation/apache/django.wsgi
  sed -i "s#mPath#"$path"#g" Automation/settings.py


  ######################################################################
  #
  # changes in django.wsgi file 
  #
  ######################################################################

  #sed -i "s/user_name/$NAME/" Automation/apache/django.wsgi 

  ######################################################################
  #
  # changes in httpd.conf file
  #
  #######################################################################

  # need sudo power for this

  sudo bash -c  "cat Automation/other_files/hhtp_cont >> /etc/apache2/httpd.conf"   
  #this appends the text from the file to the httpd.connf


  #sed -i "s/user_name/$NAME/" /etc/apache2/httpd.conf           
      #this replaces the word to the username


  #######################################################################
  #
  # creating the database and the further changes required by the user
  #
  #######################################################################


  mysqlbash_path='/usr/bin/mysql'             #mysql path address
  mysqlbash="$mysqlbash_path --user=$db_user --password=$db_password -e"  #declaring a variable
  $mysqlbash "create database $db_name "      #creates databases with the name defined by the user

  # a new database is created

  echo ""
  echo ""
  a=1
  while [ $a -ne 2 ]
  do
  {
    read -p "Enter 'Yes' for the demo(test) database & 'No' for blank database : "  db_yesno

#this checks for every yes condition the user might enter in.
    if [ $db_yesno = y ] || [ $db_yesno = Y ] || [ $db_yesno = yes ] || [ $db_yesno = YES ] || [ $db_yesno = Yes ]     
    then 
        echo ""
        echo "Now you get the demo database in your database"
        echo "Get ready to use TCC automation software"
        echo ""
        
# this imports demo.sql to the database defined by the user
        mysql --user=$db_user --password=$db_password $db_name < Automation/other_files/demo.sql 
        cd Automation/

# this creates a new superuser
        python manage.py createsuperuser
        break        


#defined every possible no condition
    elif [ $db_yesno = n ] || [ $db_yesno = N ] || [ $db_yesno = no ] || [ $db_yesno = NO ] || [ $db_yesno = No ]
    then
        echo ""
        echo "Now you get a new(blank) database"
        echo "Enjoy your experience"
        echo ""
        cd Automation/
        python manage.py syncdb                   #creates a blnk database for use, using django commands

# scelect count(*) , counts the number of enteries in the table
        result1=`mysql --user=$db_user --password=$db_password --skip-column-names -e "use $db_name;" -e "select count(*) from auth_user;"`
        
# ths checks if the count is zero or not
        if [ $result1 = 0 ]
        then
             echo ""
             echo "you need to create a superuser"
#this creates a superuser
             python manage.py createsuperuser

        else
         echo ""
        fi

# there is a need to enter Organisation details in the database.
       echo ""
       echo "Now get ready to ADD Organisation details to your software."
       echo ""
       read -p "enter organisation id :" id
       read -p "enter organisation name :" name
       read -p "enter organisation address :" address
       read -p "phone/contact number :" phone
       read -p "Director of the Organisation :" dir
#read -p "logo" logo

# this Inserts into the table the input values.
       mysql  --user=$db_user --password=$db_password $db_name << EOF
       Insert into tcc_organisation (id, name, address, phone, director) values("$id", "$name", "$address", "$phone", '$dir');
EOF


# There is a need to enter Department details in the database.
       echo ""
       echo "Now get ready to ADD Departmant details to your software."
       echo ""
       read -p "enter the Department id :" id
       read -p "enter Department name :" name
       read -p "enter Department address :" address
       read -p "phone/contact number :" phone
       read -p "Dean of the Department:" dean
       read -p "enter the fax number :" faxno

# this inserts values into corresponding fields in tcc_department table
       mysql  --user=$db_user --password=$db_password $db_name << EOF
       Insert into tcc_department (id, organisation_id, name, address, phone, dean, faxno) values( "$id", 1, "$name", "$address", "$phone", '$dean', "$faxno");
EOF
       break
  else
       echo ""
       echo "Wrong Input"
       echo ""
       echo "Enter 'Yes' for the demo database"
       echo "Enter 'No' for the new(blank) database"
       echo ""
  fi
  }
done
}

restart()
{
  sudo /etc/init.d/apache2 restart               #restarts apache
}

browser()
{
  gnome-open http://localhost/automation/
}

check()
{
  echo ""
  echo "######################################################"
  echo "#                                                    #"
  echo "#    DOWNLOADING---Automation software---            #"
  echo "#                                                    #"
  echo "######################################################"
  echo ""
   
   #this clones the Automation folder from github
   git clone https://github.com/sandeepmadaan/Automation.git

   backup       #backs up important files in other_files folder(/Automation/other_files/)
   media        #copies media folder into (~/contrib/admin/)
   run          #runs run function
   restart      #runs browser function
   browser      #runs browser function
}


main()   #this is the first function, and installs secondary requirements
{
  echo "-------installing required packages------"
  sudo apt-get install apache2 libapache2-mod-wsgi 
  sudo apt-get install python-mysqldb
  sudo apt-get install python-setuptools
  sudo easy_install pip
  echo ""
  echo "-------installing django modules---------"
  sudo pip install django-registration
  sudo pip install django-tagging

  

###################################################################
#
#
# checking automation folder before in home directory
#
#
###################################################################

 echo "now we test if there is any folder named Automation that exists in home directory"
 if (test -d Automation)              #check if the same folder exits 
    then

######################################################################
#
# this part makes sure that if there is any existing Automation folder 
# in home directory then it renames it with Automation.date.time
#
#######################################################################
 
      mDate=$(date +%Y%m%d%H:%M:%S)     #this stores date in variable mDate
      for mFName in $PWD/Automation
         do
            mPref=${mFName%.log}
            echo $mPref | egrep -q "\.[0-9]{10}:[0-9]{2}:[0-9]{2}"
            [ $? -eq 0 ] && continue
            mv ${mFName} ${mPref}.${mDate}
            echo $PWD3
      done

 fi
 check 
}

#####################################################################################
#
#
#    Script starts here, basic requirements being checked
#
#
#####################################################################################

django()
{
 if  [ ! -d /usr/local/lib/python2.7/dist-packages/django ]  #checks if django is installed with python 2.7
    then
       wget http://www.djangoproject.com/m/releases/1.4/Django-1.4.2.tar.gz     # download tar folder of django
       sudo tar xzvf Django-1.4.2.tar.gz                                             # opens the tar file
       cd Django-1.4.2                                                          # get into the django folder
       sudo python setup.py install             
           
 fi
main
}

# Script starts here
if  [ ! -f /usr/bin/mysql ]  # checks if django and mysql are installed on the system 
   then      
      sudo apt-get install mysql-server
fi
django

