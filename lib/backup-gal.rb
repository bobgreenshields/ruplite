require './ruplite'
require 'logger'

DATA_SRC = '/mnt/data'
DATA_TGT = 'file:////mnt/media/backups'
KEYS = ['--encrypt-key 87909562', '--sign-key F899621D']
FULL_OPT = ['--full-if-older-than 30D']
SIGN_PHRASE = 'xxx'
ENCRYPT_PHRASE = "********"
LOG_FILE = '/var/log/backup.log'

data_cfg = {}
data_cfg[:source] = DATA_SRC
data_cfg[:target] = DATA_TGT
data-cfg[:options] = ['--include /mnt/data/apps/**/*lic*']
data-cfg[:options] << ['--include /mnt/data/apps/**/*key*']
data-cfg[:options] << ['--exclude /mnt/data/apps']
data_cfg[:options] << FULL_OPT
data_cfg[:options] << KEYS
data_cfg[:passphrase] = SIGN_PHRASE

SECURE_SRC = '/mnt/secure'
SECURE_TGT = 'file:////mnt/media/backups'
secure_cfg = {}
secure_cfg[:source] = SECURE_SRC
secure_cfg[:target] = SECURE_TGT
secure_cfg[:options] = FULL_OPT
secure_cfg[:options] << KEYS
secure_cfg[:passphrase] = SIGN_PHRASE

verify_secure_cfg = {}
verify_secure_cfg[:source] = SECURE_TGT
verify_secure_cfg[:target] = SECURE_SRC
verify_secure_cfg[:options] << KEYS
verify_secure_cfg[:action] = "verify"
verify_secure_cfg[:passphrase] = ENCRYPT_PHRASE

#log = Logger.new(STDOUT)
log = Logger.new(LOG_FILE, 10, 1024000)

data = Ruplite.new('data', data_cfg, logger)
puts data.run
#secure = Ruplite.new('secure', secure_cfg, logger)
#
#verify_secure = Ruplite.new('secure', verify_secure_cfg, logger)
