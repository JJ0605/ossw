#!/bin/bash

u_item="$1"
u_data="$2"
u_user="$3"

echo "---------------------------------------"
echo "User name: Lee JeongJin"
echo "Student Number: 12181660"
echo "[   MENU   ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of 'action' genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with age between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "---------------------------------------"

while true; do
    echo -e "\nEnter your choice [ 1-9 ]:"
    read -r option

    case $option in
        1)
            echo -e "\nPlease enter 'movie id'(1~1682):"
            read -r movie_id
            awk -F '|' -v id="$movie_id" '$1==id { print }' "$u_item"
            ;;
        2)
            echo -e "\nDo you want to get the data of 'action' genre movies from 'u.item'?(y/n):"
            read -r answer
            if [ "$answer" == "y" ]; then
                awk -F '|' 'BEGIN {count=0} $7==1 && count < 10 { gsub(/\([0-9]+\)/, "", $2); printf "%s %s (%s)\n", $1, $2, substr($3, 8, 4); count++ }' "$u_item"
            else echo -e "Canceled"
            fi
            ;;
        3)
            echo -e "\nPlease enter the 'movie id'(1~1682)"
            read -r movie_id
            awk -F'\t' -v id="$movie_id" '$2==id { sum+=$3; count++ } END { if (count > 0) printf "%.5f\n", sprintf("%.6f", sum/count); else printf "No ratings" }' "$u_data"
            ;;
        4)
            echo -e "\nDo you want to delete the 'IMDb URL' from 'u.item'?(y/n):"
            read -r answer
            if [ "$answer" == "y" ]; then
                awk -F'|' 'BEGIN {OFS="|"; count=0} { $5=""; print; count++; if (count >= 10) exit }' "$u_item"
            else echo -e "\nIMDb URLs are not deleted."
            fi
            ;;
        5)
            echo -e "\nDo you want to get the data about users from 'u.user'?(y/n):"
            read -r answer
            if [ "$answer" == "y" ]; then
                awk -F'|' 'BEGIN {count=0} {gender = ($3 == "F") ? "female" : "male"; printf "user %s is %s years old %s %s\n", $1, $2, gender, $4; count++; if (count >= 10) exit}' "$u_user"
            else echo -e "\nCanceled"
            fi
            ;;
        6)
            echo -e "\nDo you want to Modify the format of 'release date' in 'u.item'?(y/n):"
            read -r answer
            if [ "$answer" == "y" ]; then
                awk -F'|' 'BEGIN {OFS="|"} NR >= 1673 && NR <= 1682 {
                    split($3, a, "-");
                    months["Jan"] = "01"; months["Feb"] = "02"; months["Mar"] = "03"; months["Apr"] = "04";
                    months["May"] = "05"; months["Jun"] = "06"; months["Jul"] = "07"; months["Aug"] = "08";
                    months["Sep"] = "09"; months["Oct"] = "10"; months["Nov"] = "11"; months["Dec"] = "12";
                    $3 = a[3] months[a[2]] a[1];
                    print;
                }' "$u_item"
            else
                echo -e "\nCanceled."
            fi
            ;;
        7)
            echo "Please enter the 'user id' (1~943):"
            read -r answer
            awk -F'\t' -v id="$answer" '$1==id { print $2 }' u.data | sort -n | awk 'BEGIN { ORS="|" } { print $0 }'
            echo -e "\n"
            awk -F'\t' -v id="$answer" '$1==id { print $2 }' u.data | sort -n | head -10 | while read -r input
            do
                awk -F'|' -v id="$input" '$1==id { printf "%s|%s\n", $1, $2 }' u.item
            done
            ;;
        8)
            echo -e "\nDo you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):"
            read -r answer
            if [ "$answer" == "y" ]; then
                awk -F'|' '$2 >= 20 && $2 <= 29 && $4 == "programmer" { print $1 }' u.user > temp.txt
                awk -F'\t' 'NR==FNR { ids[$1]; next } $1 in ids { sum[$2] += $3; count[$2]++ } END { for (i in sum) { rounded_avg = sprintf("%.6f", sum[i]/count[i]); printf "%s %g\n", i, rounded_avg } }' temp.txt u.data | sort -k1,1n
            else 
                echo -e "Canceled"
            fi
            ;;
        9)
            echo -e "Bye"
            exit 0
            ;;
        *)
            echo -e "Error: Type again"
            ;;
    esac
done
