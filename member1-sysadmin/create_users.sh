#!/bin/bash
# Member 1: SysAdmin (User Creation)

echo "Creating student groups..."
groupadd class_a
groupadd class_b
groupadd class_c

echo "Creating 100 student accounts..."
echo "Username,Password" > ../initial_passwords.csv

for i in {1..100}; do
    username="student${i}"
    password=$(openssl rand -base64 6)
    
    if [ $i -le 33 ]; then
        usergroup="class_a"
    elif [ $i -le 66 ]; then
        usergroup="class_b"
    else
        usergroup="class_c"
    fi

    useradd -m -g $usergroup -s /bin/bash $username
    echo "${username}:${password}" | chpasswd
    chage -d 0 $username
    echo "${username},${password}" >> ../initial_passwords.csv
done

echo "100 users created successfully! Passwords saved to initial_passwords.csv."
