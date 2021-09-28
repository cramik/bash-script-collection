mkdir compressed_files/
find -type f -size +8000k -iname *.jpg -exec jpegoptim -S7500 -d compressed_files/ {} \;