# Indexing CRAN Packages

This project indexes all the available packages on a CRAN server, extracts information for each package, and stores it in a single file. The information is stored in key:value format, and includes the following fields:

- name
- version
- dependencies
- title
- description
- authors
- maintainers
- license

To execute the code locally, please follow these steps:

  1. Install Ruby version 2.7 or higher on your system and bundler with `gem install bundler`.
  2. Clone this repository, navigate to the project directory in your terminal, Install the required dependencies by running bundle install.
  3. Create a .env file in the root of the project with the following content:

  ```
    CRAN_SERVER_URL=https://cran.r-project.org/src/contrib/PACKAGES
    FILE_NAME_PATH='packages_info.txt'
    FILE_NAME_PATH_TEST='spec/packages_info_test.txt'
  ```

  You can change the value of CRAN_SERVER_URL to use a different CRAN mirror, and FILE_NAME_PATH to specify a different name and location for the output file.

  4. Run the script by executing ruby index_cran_packages.rb. This will create a file called `packages_info.txt` in the project directory.



# Tests
To run the tests, use the following command:

```
rspec spec
```

# Start the scheduler

run in the terminal the command this command:

```
ruby schedule.rb
```

The scheduled job will run daily at 6am and update the package information file.
