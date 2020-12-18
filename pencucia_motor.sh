#! /bin/bash

## fungsi untuk menambah/mencatat pendaftaran
addAntrian()
{
    ## validasi plat
    is_valid="false"
    while [[ $is_valid == "false" ]]; do
        read -p "Masukan plat nomor : " plat
        read -p "Masukan nama       : " nama
        
        ### validasi ###
        
        local can_use="true"
        # pengecekan di list antrian
        for ((i = 1; i <= ${n_antri}; i++)); do
            if [ "${plat}" == "${list_antrian[plat${i}]}"  ]; then
                can_use="false"
                # echo -e "** Plat salah, ulangi **\n"
                break
            fi
        done
        
        # pengecekan di list transaksi
        if [[ $can_use == "true" ]]; then
            for ((i = 1; i <= ${n_trans}; i++)); do
                if [ "${plat}" == "${list_transaksi[plat${i}]}"  ]; then
                    can_use="false"
                    # echo -e "** Plat salah, ulangi **\n"
                    break
                fi
            done
        fi
        
        # menghentikan loop
        if [[ $can_use == "true" ]]; then is_valid="true";
        else
            echo "** Plat salah, ulangi **\n"
        fi
    done
    
    ## VALIDASI BERHASIL ##
    #increment jumlah data
    n_antri=$(($n_antri+1))
    
    # insert data ke dalam array
    list_antrian+=([plat${n_antri}]=${plat})
    list_antrian+=([nama${n_antri}]=${nama})
    
    echo "Data berhasil ditambahkan ke antrian"
}

showListAntrian()
{
    # Fungsi menampilka semua daftar antrian yang ada
    
    if [ $n_antri -eq 0 ]; then echo "Antrian kosong"
    else
        # reset file antrian
        echo "" > antrian.txt
        echo "Daftar Antrian Cuci motor"
        echo "-----------------------------------------"
        echo "|~No.~|~plat~|~Nama" >> antrian.txt
        
        # Memasukan data kedalam file antrian
        for ((i = 1; i <= ${n_antri}; i++)); do
            echo "|~${i}~|~${list_antrian[plat${i}]}~|~${list_antrian[nama${i}]}" >> antrian.txt
        done
        
        # cetak data yang ada dialam file antrian
        # menggunakan kolom agar rapi
        # kolom dibedakan dengan tanda tilde '~'
        cat antrian.txt | column -t -s '~'
        
        echo "-----------------------------------------"
    fi
}

addTransaksi()
{
    #################
    # fungsi untuk menambahkan data transaksi
    # data antrian akan diambil
    # dan dipindahkan ke data transaksi
    ##
    
    if [ $n_antri -eq 0 ]; then echo "Antrian kosong"
    else
        echo "Antrian dengan plat ${list_antrian[plat1]} akan di proses"
        echo "Nama customer ${list_antrian[nama1]}"
        read -p "Merk motor : " motor
        echo "Jasa :"
        echo "  1. Cuci Salju++"
        echo "  2. Cuci Salju"
        echo "  3. Cuci Biasa"
        
        ## pilihan jasa pencucian
        local jasa
        while :; do
            read -p "pilih ? " jasa
            
            case "$jasa" in
                1)  biaya=$((20000)); break ;;
                2)  biaya=$((15000)); break ;;
                3)  biaya=$((10000)); break ;;
                *)  echo "masukan salah" ;;
            esac
        done
        
        #### masukana data kedalam array list_transaksi
        ## ambil data dari list_antrian
        local plat_temp=${list_antrian[plat1]}
        local nama_temp=${list_antrian[nama1]}
        
        n_trans=$(($n_trans+1))
        list_transaksi+=([plat${n_trans}]=$plat_temp)
        list_transaksi+=([nama${n_trans}]=$nama_temp)
        list_transaksi+=([motor${n_trans}]=$motor)
        list_transaksi+=([biaya${n_trans}]=$biaya)
        
        ## mengurangi kumlah list yang ada di antrian
        for ((i = 1; i <= ${n_antri}; i++)); do
            # plat_temp=${list_antrian[plat$(($i+1))]}
            # nama_temp=${list_antrian[nama$(($i+1))]}
            
            # list_antrian[plat${i}]=$plat_temp
            # list_antrian[nama${i}]=$nama_temp
            list_antrian[plat${i}]=${list_antrian[plat$(($i+1))]}
            list_antrian[nama${i}]=${list_antrian[nama$(($i+1))]}
        done
        
        ## menghapus list antrian terakhir
        unset list_antrian[plat${n_antri}]
        unset list_antrian[nama${n_antri}]
        n_antri=$(($n_antri-1))
        
        echo "Penambahan berhasil"
    fi
}

editTransaksi()
{
    if [ $n_trans -eq 0 ]; then echo "Data kosong"
    else
        echo "UBAH DATA TRANSAKSI"
        local plat_temp
        read -p "Masukan plat nomor yang akan diedit transaksi : " plat_temp
        
        ## cari plat di daftar transaksi
        local is_found="false"
        for ((i = 1; i<= n_trans; i++)); do
            if [ "${plat_temp}" == "${list_transaksi[plat${i}]}" ]; then
                local idx=${i}
                is_found="true"
                break
            fi
        done
        
        ### apakah ketemu atau tidak
        if [[ $is_found == "true" ]]; then
            read -p "masukan nama baru  : " list_transaksi[nama${idx}]
            read -p "masukan merk motor : " list_transaksi[motor${idx}]
            
            echo "Jasa :"
            echo "  1. Cuci Salju++"
            echo "  2. Cuci Salju"
            echo "  3. Cuci Biasa"
            
            local jasa
            while :; do
                read -p "pilih ? " jasa
                
                case "$jasa" in
                    1)  list_transaksi[biaya${idx}]=$((20000)); break ;;
                    2)  list_transaksi[biaya${idx}]=$((15000)); break ;;
                    3)  list_transaksi[biaya${idx}]=$((10000)); break ;;
                    *)  echo "masukan salah" ;;
                esac
            done
            
            echo "Data berhasil diubah"
        else
            echo "Plat nomor tidak ditemukan"
        fi
    fi
}

showListTransaksi()
{
    if [ $n_trans -eq 0 ]; then echo "Data kosong"
    else
        for ((i = 1; i <= ${n_trans}; i++)); do
            ##################
            # Fungsi menampilkan semua daftar  yang ada
            ###
            
            # reset file antrian
            echo "" > transaksi.txt
            echo "Daftar Transaksi Cuci motor"
            echo "---------------------------------------------------------------------------"
            echo "|~No.~|~plat~|~Nama~|~Merk Motor~|~Biaya" >> transaksi.txt
            echo "~ " >> transaksi.txt
            # Memasukan data kedalam file antrian
            local total=0
            for ((i = 1; i <= ${n_trans}; i++)); do
                echo "|~${i}~|~${list_transaksi[plat${i}]}~|~${list_transaksi[nama${i}]}~|~${list_transaksi[motor${i}]}~|~${list_transaksi[biaya${i}]}~" >> transaksi.txt
                total=$(( ${total} + ${list_transaksi[biaya${i}]} ))
            done
            
            # cetak data yang ada dialam file antrian
            # menggunakan kolom agar rapi
            # kolom dibedakan dengan tanda tilde '~'
            cat transaksi.txt | column -t -s '~'
            echo
            echo "Total = Rp. ${total}"
            
            echo "---------------------------------------------------------------------------"
        done
    fi
}

deleteTransaksi()
{
    if [ $n_trans -eq 0 ]; then echo "Data kosong"
    else
        echo "HAPUS DATA TRANSAKSI"
        local plat_temp
        read -p "Masukan plat nomor yang akan dihapus transaksi : " plat_temp
        
        ## cari plat di daftar transaksi
        local is_found="false"
        for ((i = 1; i<= n_trans; i++)); do
            if [ "${plat_temp}" == "${list_transaksi[plat${i}]}" ]; then
                local idx=${i}
                is_found="true"
                break
            fi
        done
        
        ### apakah ketemu atau tidak
        if [[ $is_found == "true" ]]; then
            
            ## tampilakn data yang akan dihapus
            echo "No Plat       : ${list_transaksi[plat${idx}]}"
            echo "Nama Customer : ${list_transaksi[nama${idx}]}"
            echo "Mrk Motor     : ${list_transaksi[motor${idx}]}"
            echo "Biaya         : ${list_transaksi[biaya${idx}]}"
            
            ## konfirmasi
            local answer
            read -p "apakah data akan dihapus [y/t] ? " answer
            
            if [[ $answer == "y" ]]; then
                for ((i = $idx; i <= $n_trans; i++)); do
                    ## timpa data
                    list_transaksi[plat${i}]=${list_transaksi[plat$(($i+1))]}
                    list_transaksi[nama${i}]=${list_transaksi[nama$(($i+1))]}
                    list_transaksi[motor${i}]=${list_transaksi[motor$(($i+1))]}
                    list_transaksi[biaya${i}]=${list_transaksi[biaya$(($i+1))]}
                done
                
                ## menghapus data terakhir
                unset list_transaksi[plat${n_trans}]
                unset list_transaksi[nama${n_trans}]
                unset list_transaksi[motor${n_trans}]
                unset list_transaksi[biaya${n_trans}]
                n_trans=$(($n_trans-1))
                echo "Data berhasil dihapus"
            else
                echo "dibatalkan"
            fi
            
        else
            echo "plat nomor tidak ditemukan"
        fi
    fi
}



########### MAIN PROGRAM ###########
## Deklarasi variable
## list antrian ['plat', 'nama']
declare -A list_antrian

## list proses [plat, 'nama', 'motor', 'biaya']
declare -A list_transaksi
declare -i n_antri=0
declare -i n_trans=0

while :; do
    clear
    figlet -c "Pencucian Motor"
    
    echo "Menu :"
    echo " 1. Tambah Antrian"
    echo " 2. Tambah Proses Transaksi"
    echo " 3. Daftar Antrian"
    echo " 4. Daftar Transaksi"
    echo " 5. Ubah Data Transaksi"
    echo " 6. Hapus Data Transaksi"
    echo " 0. Keluar"
    echo
    read -p "masukan pilihan menu : " answer
    echo
    
    case "$answer" in
        1)  addAntrian ;;
        2)  addTransaksi ;;
        3)  showListAntrian ;;
        4)  showListTransaksi ;;
        5)  editTransaksi ;;
        6)  deleteTransaksi ;;
        0)  echo Terimakasih; exit ;;
        *)  echo "Pilihan salah" ;;
    esac
    read
done