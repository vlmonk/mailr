require 'openssl'
require 'digest/sha2'
require 'digest/sha1'
require 'base64'

module EzCrypto


=begin rdoc
The Key is the only class you need to understand for simple use.

=== Algorithms

The crypto algorithms default to aes-128-cbc however on any of the class methods you can change it to one of the standard openssl cipher names using the
optional <tt>:algorithm=>alg name</tt> parameter.

Eg. 
    Key.new @raw, :algorithm=>"des"
    Key.generate :algorithm=>"blowfish"
    Key.with_password @pwd,@salt,:algorithm=>"aes256"    


== License

Action Web Service is released under the MIT license.


== Support

To contact the author, send mail to pelleb@gmail.com

Also see my blogs at:
http://stakeventures.com and
http://neubia.com

This project was based on code used in my project StakeItOut, where you can securely share web services with your partners.
https://stakeitout.com

(C) 2005 Pelle Braendgaard

=end

  class Key
    attr_reader :raw,:algorithm
    
=begin rdoc
Initialize the key with raw unencoded binary key data. This needs to be at least
16 bytes long for the default aes-128 algorithm.
=end
    def initialize(raw,options = {})
      @raw=raw
      @algorithm=options[:algorithm]||"aes-128-cbc"
    end
    
=begin rdoc
Generate random key.
=end
    def self.generate(options = {})      
      Key.new(EzCrypto::Digester.generate_key(calculate_key_size(options[:algorithm])),options)
    end
            
=begin rdoc
Create key generated from the given password and salt  
=end
    def self.with_password(password,salt,options = {})
      Key.new(EzCrypto::Digester.get_key(password,salt,calculate_key_size(options[:algorithm])),options)
    end
    
=begin rdoc
Initialize the key with Base64 encoded key data.
=end
    def self.decode(encoded,options = {})
      Key.new(Base64.decode64(encoded),options)
    end
    
=begin rdoc
Encrypts the data with the given password and a salt. Short hand for:

  key=Key.with_password(password,salt,options)
  key.encrypt(data)

=end
    def self.encrypt_with_password(password,salt,data,options = {})
      key=Key.with_password(password,salt,options)
      key.encrypt(data)
    end
    
=begin rdoc
Decrypts the data with the given password and a salt. Short hand for:

  key=Key.with_password(password,salt,options)
  key.decrypt(data)

  
=end
    def self.decrypt_with_password(password,salt,data,options = {})
      key=Key.with_password(password,salt,options)
      key.decrypt(data)
    end
    
=begin rdoc
Given an algorithm this calculates the keysize. This is used by both the generate and with_password methods. This is not yet 100% complete.  
=end
    def self.calculate_key_size(algorithm)    
      if !algorithm.nil?
        algorithm=~/^([[:alnum:]]+)(-(\d+))?/
        if $3
          size=($3.to_i)/8
        else 
          case $1 
            when "bf"
              size = 16
            when "blowfish"
              size = 16
            when "des"
              size = 8
            when "des3"
              size = 24
            when "aes128"
              size = 16
            when "aes192"
              size = 24
            when "aes256"
              size = 32
            when "rc2"
              size = 16
            when "rc4"
              size = 16
            else 
              size = 16
            end
        end
      end
      if size.nil?
        size = 16
      end
      
      size
    end

=begin rdoc
returns the Base64 encoded key.
=end
    def encode
      Base64.encode64 @raw
    end
    
=begin rdoc
returns the Base64 encoded key. Synonym for encode.  
=end
    def to_s
      encode
    end
    
=begin rdoc
Encrypts the data and returns it in encrypted binary form.
=end
    def encrypt(data)
      @cipher=EzCrypto::Encrypter.new(self,"",@algorithm)
      @cipher.encrypt(data)
    end

=begin rdoc
Encrypts the data and returns it in encrypted Base64 encoded form.
=end
    def encrypt64(data)
      Base64.encode64(encrypt(data))
    end
    
=begin rdoc
Decrypts the data passed to it in binary format.
=end    
    def decrypt(data)
      @cipher=EzCrypto::Decrypter.new(self,"",@algorithm)
      @cipher.gulp(data)
    rescue
      puts @algorithm
      throw $!
    end
    
=begin rdoc
Decrypts a Base64 formatted string  
=end
    def decrypt64(data)
      decrypt(Base64.decode64(data))
    end

    
  end
=begin rdoc
Abstract Wrapper around OpenSSL's Cipher object. Extended by Encrypter and Decrypter.
  
You probably should be using the Key class instead.

Warning! The interface may change.

=end
  class CipherWrapper

=begin rdoc
  
=end
    def initialize(key,target,mode,algorithm)
      @cipher = OpenSSL::Cipher::Cipher.new(algorithm)  
      if mode
        @cipher.encrypt
      else
        @cipher.decrypt
      end
      @cipher.key=key.raw
      @cipher.padding=1
      @target=target
      @finished=false
    end
    
=begin rdoc
Process the givend data with the cipher.
=end
    def update(data)
      reset if @finished
      @target<< @cipher.update(data)
    end

=begin rdoc
  
=end
    def <<(data)
      update(data)
    end
    
=begin rdoc
Finishes up any last bits of data in the cipher and returns the final result.
=end
    def final
      @target<< @cipher.final
      @finished=true
      @target
    end
    
=begin rdoc
Processes the entire data string using update and performs a final on it returning the data.
=end
    def gulp(data)
      update(data)
      final 
    end  

=begin rdoc
  
=end
    def reset(target="")
      @target=target
      @finished=false
    end
  end

=begin rdoc
Wrapper around OpenSSL Cipher for Encryption use.

You probably should be using Key instead.

Warning! The interface may change.

=end
  class Encrypter<EzCrypto::CipherWrapper

=begin rdoc
  
=end
    def initialize(key,target="",algorithm="aes-128-cbc")
      super(key,target,true,algorithm)
    end
    
=begin rdoc
  
=end    
    def encrypt(data)    
      gulp(data)
    end
  end

=begin rdoc
Wrapper around OpenSSL Cipher for Decryption use.

You probably should be using Key instead.

Warning! The interface may change.
=end
  class Decrypter<EzCrypto::CipherWrapper
=begin rdoc
  
=end
    def initialize(key,target="",algorithm="aes-128-cbc")
      super(key,target,false,algorithm)
    end
    
=begin rdoc
  
=end    
    def decrypt(data)
      gulp(data)
    end
  end

=begin rdoc

=end
  class Digester    
=begin rdoc
Various handy Digest methods. 

Warning! The interface may change.
=end
    def self.get_key(password,salt,size)
        digest(salt+password,size)
    end
  
=begin rdoc
  
=end
    def self.generate_key(size=16)
        key=OpenSSL::Random.random_bytes(size)
        digest(key,size)
    end
  
=begin rdoc
  
=end
    def self.generate_key64(size=32)
        key=OpenSSL::Random.random_bytes(size)
        digest(key,size)
    end   
    
=begin rdoc
  
=end
    def self.digest(data,size=16)
      if size==0
        ""
      elsif size<=16
        Digest::SHA1.digest(data)[0..(size-1)]
      else
        Digest::SHA256.digest(data)[0..(size-1)]
      end
    end
    
=begin rdoc
  
=end
    def self.digest64(data)
      Base64.encode64(digest(data))
    end
	end

end


