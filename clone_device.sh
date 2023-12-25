#!/bin/bash
# A repo URL has to be inputed in the input line.
# Get the repo URL from the Android dumps repo (https://dumps.tadiphone.dev/dumps/)
# Then go to brand_name --> device_name --> clone button.

# single file checkouts for inputed repo
checkout() {
  echo -e "\n# Try to get build.prop from system dirs"
  git checkout $branch_name -- system/build.prop
  git checkout $branch_name -- system/system/build.prop

  echo -e "\n# Try to get build.prop from system/product dirs"
  git checkout $branch_name -- system/system/product/build.prop
  git checkout $branch_name -- system/product/build.prop

  echo -e "\n# Try to get build.prop from vendor dirs"
  echo
  git checkout $branch_name -- vendor/build.prop 
  git checkout $branch_name -- system/vendor/build.prop

  retry_checkout
}

retry_checkout() {
  echo -e "\n# Try again to get build.prop from system dirs"
  git checkout $branch_name -- system/build.prop
  git checkout $branch_name -- system/system/build.prop

  echo -e "\n# Try again to get build.prop from system/product dirs"
  git checkout $branch_name -- system/system/product/build.prop
  git checkout $branch_name -- system/product/build.prop

  echo -e "\n# Try again to get build.prop from vendor dirs"
  echo
  git checkout $branch_name -- vendor/build.prop 
  git checkout $branch_name -- system/vendor/build.prop

  rename
}

# rename and move files that are clones
rename() {
  echo -e "\n# Rename and move files..."
  if [ -f "system/product/build.prop" ]; then
    mv system/product/build.prop ./product-build.prop
  elif [ -f "system/system/product/build.prop" ]; then
    mv system/system/product/build.prop ./product-build.prop
  fi

  if [ -f "system/build.prop" ]; then
    mv system/build.prop ./
  elif [ -f "system/system/build.prop" ]; then
    mv system/system/build.prop ./
  fi

  if [ -f "system/vendor/build.prop" ]; then
      mv system/vendor/build.prop ./vendor-build.prop
  fi
  if [ -f "vendor/build.prop" ]; then
    mv vendor/build.prop ./vendor-build.prop
  fi

  delete
}

# delete empty folders when finished
delete() {
  if [ -d "system" ]; then
  rm -rf system
  fi
  if [ -d "vendor" ]; then
    rm -rf vendor
  fi
  # Navigate to parent directory
  cd ../
}

echo "### Git clone script for phone FP dumps ###"
echo -e "Script by Juleast @ https://github.com/juleast \
        \n"

# main script
read -p "Paste repo URL here: " url
if [ "$url" = ""  ]; then
  echo -e "### No repo link was pasted! ### \n#"
  echo -e "# Please Note!!"
  echo -e "# Make sure you are pasting the proper URL" \
  "\n# URL formats such as https://dumps.tadiphone.dev/dumps/asus/asus_i007_1.git"
  echo -e "# Rerun program after copying the correct URL \n#"
  return 1
elif [[ $(echo $url | grep "https://") != "" ]] && [[ $(echo "$url" | grep ".git") != "" ]]; then
  IFS='/' read -r -a url_arr <<< "$url"
  IFS='.' read -r -a git_dir_arr <<< "${url_arr[-1]}"
  git_dir=${git_dir_arr[0]}
  
  if [ -d "$git_dir" ]; then
    echo "Deleting $git_dir..."
    rm -rf "$git_dir"
    echo "$git_dir deleted successfully."
  else
    echo "$git_dir does not exist. Nothing to delete."
  fi
  
  echo "--- List of the available branches ---"
  git ls-remote --heads ${url}
  read -p "Enter the branch name: " branch_name
  
  git clone --depth 1 --no-checkout --filter=blob:none -b $branch_name ${url}

  cd ${git_dir[0]}

  checkout
else
  echo -e "# Invalid URL!"
  echo -e "# Please rerun script and paste a valid git URL."
  return 1
fi
