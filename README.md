# otp-info-generator

There is some scripts for generate sets of user files in [MultiOTP](https://github.com/multiOTP) instance with AD backend in Windows family OS.

Set of user files is the set of files for user-device settings in zip-archive with filename same as provided username.

Every generated archive contains:
- QR-code in .png file
- text-link in .txt file
- seed-phrase (separately by text-link) in .txt file  

*1_user_OTP_info_generator.ps1* - generate set of files for just one username provided in command-line argument or from user prompt if argument isn't provided.

*multiuser_OTP_info_generator.ps1* - generate several sets of files just from usernames provided with arguments.

*allusers_OTP_info_generator.ps1* - generate sets of files from names from AD group.

Every script make prompt to synchronize AD users with local database before making it main task.

*There's no user existence checks or checks for any other possible errors, because it's overcoding for that's simple tasks.*

*I want to merge all this functions to one script in the future.*
