#!/bin/bash


backup(){
echo_backup+=("\n🄱 🄰 🄲 🄺 🅄 🄿 🅂")
echo_backup+=("Number of backups was set to $number_of_backups")
date=$(date '+%Y_%m_%d_%H_%M_%S')
[[ "$verbose" == "true" ]] && cli -c 'app kubernetes backup_chart_releases backup_name=''"'HeavyScript_"$date"'"' &> /dev/null && echo_backup+=(HeavyScript_"$date")
[[ -z "$verbose" ]] && echo_backup+=("\nNew Backup Name:") && cli -c 'app kubernetes backup_chart_releases backup_name=''"'HeavyScript_"$date"'"' | tail -n 1 &> /dev/null && echo_backup+=(HeavyScript_"$date")
mapfile -t list_backups < <(cli -c 'app kubernetes list_backups' | grep "HeavyScript_" | sort -t '_' -Vr -k2,7 | awk -F '|'  '{print $2}'| tr -d " \t\r")
if [[  ${#list_backups[@]}  -gt  "$number_of_backups" ]]; then
    echo_backup+=("\nDeleted the oldest backup(s) for exceeding limit:")
    overflow=$(( ${#list_backups[@]} - "$number_of_backups" ))
    mapfile -t list_overflow < <(cli -c 'app kubernetes list_backups' | grep "HeavyScript_"  | sort -t '_' -V -k2,7 | awk -F '|'  '{print $2}'| tr -d " \t\r" | head -n "$overflow")
    for i in "${list_overflow[@]}"
    do
        cli -c 'app kubernetes delete_backup backup_name=''"'"$i"'"' &> /dev/null || echo_backup+=("Failed to delete $i")
        echo_backup+=("$i")
    done
fi

#Dump the echo_array, ensures all output is in a neat order. 
for i in "${echo_backup[@]}"
do
    echo -e "$i"
done
}
export -f backup



deleteBackup(){
while true
do
    clear -x && echo "pulling all restore points.."
    list_backups=$(cli -c 'app kubernetes list_backups' | sort -t '_' -Vr -k2,7 | tr -d " \t\r"  | awk -F '|'  '{print $2}' | nl -s ") " | column -t)
    if [[ -z "$list_backups" ]]; then
        echo "No restore points available"
        exit
    fi
    while true
    do
        clear -x
        title
        echo -e "Choose a Restore Point to Delete\nThese may be out of order if they are not HeavyScript backups"
        echo "$list_backups"
        echo
        echo "0)  Exit"
        read -rt 120 -p "Please type a number: " selection
        restore_point=$(echo "$list_backups" | grep ^"$selection)" | awk '{print $2}')
        if [[ $selection == 0 ]]; then
            echo "Exiting.." 
            exit
        elif [[ -z "$selection" ]]; then 
            echo "Your selection cannot be empty"
            sleep 3
            continue
        elif [[ -z "$restore_point" ]]; then
            echo "Invalid Selection: $selection, was not an option"
            sleep 3
            continue
        fi
        break
    done
    while true
    do
        clear -x
        echo -e "\nWARNING:\nYou CANNOT go back after deleting your restore point" 
        echo -e "\n\nYou have chosen:\n$restore_point\n\nWould you like to continue?"
        echo -e "1)   Yes\n2)   Exit\n"
        read -rt 120 -p "Please type a number: " yesno 
        case $yesno in
            1)
                echo -e "\nDeleting $restore_point"
                cli -c 'app kubernetes delete_backup backup_name=''"'"$restore_point"'"' &>/dev/null || { echo "Failed to delete backup.."; exit; }
                echo "Sucessfully deleted"
                break
                ;;
            2)
                echo "Exiting"
                exit
                ;;
            *)
                echo "That was not an option, try again"
                sleep 3
                continue
                ;;
        esac
    done
    while true
    do
        echo "Delete more?"
        echo "1)  Yes"
        echo "2)  No"
        read -rt 120 -p "Please type a number: " yesno
        case $yesno in
            1)
                break
                ;;
            2)
                exit
                ;;
            *)
                echo "$yesno was not an option, try again" 
                sleep 2
                continue
                ;;

        esac

    done
done
}
export -f deleteBackup


restore(){
while true
do
    clear -x && echo "pulling restore points.."
    list_backups=$(cli -c 'app kubernetes list_backups' | grep "HeavyScript_" | sort -t '_' -Vr -k2,7 | tr -d " \t\r"  | awk -F '|'  '{print $2}' | nl -s ") " | column -t)
    clear -x
    if [[ -z "$list_backups" ]]; then
        echo "No HeavyScript restore points available"
        exit
    else
        title
        echo "Choose a Restore Point"
    fi
    echo "$list_backups"
    echo
    echo "0)  Exit"
    read -rt 120 -p "Please type a number: " selection
    [[ $selection == 0 ]] && echo "Exiting.." && exit
    restore_point=$(echo "$list_backups" | grep ^"$selection)" | awk '{print $2}')
    #Check for valid selection. If none, kill script
    if [[ -z "$selection" ]]; then 
        echo "Your selection cannot be empty"
        sleep 3
        continue
    elif [[ -z "$restore_point" ]]; then
        echo "Invalid Selection: $selection, was not an option"
        sleep 3
        continue
    fi
    while true
    do
        clear -x
        echo -e "\nWARNING:\nThis is NOT guranteed to work\nThis is ONLY supposed to be used as a LAST RESORT\nConsider rolling back your applications instead if possible"
        echo -e "\n\nYou have chosen:\n$restore_point\n\nWould you like to continue?"
        echo -e "1)   Yes\n2)   Exit\n"
        read -rt 120 -p "Please type a number: " yesno 
        case $yesno in
            1)
                echo -e "\nStarting Backup, this will take a LONG time."
                cli -c 'app kubernetes restore_backup backup_name=''"'"$restore_point"'"' || { echo "Failed to delete backup.."; exit; }
                exit
                ;;
            2)
                echo "Exiting"
                exit
                ;;
            *)
                echo "That was not an option, try again"
                sleep 3
                continue
                ;;
        esac
    done
done
}
export -f restore