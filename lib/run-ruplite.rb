require './ruplite'
require 'logger'

config = {}

config[:source] = '/home/bobg/icon'
config[:target] = 'file:///home/bobg/backups/test'
config[:passphrase] = 'xxx'
config[:options] = ['--encrypt-key 87909562', '--sign-key 31894F89']

log = Logger.new(STDOUT)

#opts = []
#opts << '--encrypt-key 87909562'
#opts << '--sign-key 31894F89'
#
#config = {:source => src, :target => tgt, :options => opts}

#test = Ruplite.new('Test', config)
test = Ruplite.new('Test', config, log)

#puts test.run
test.run

