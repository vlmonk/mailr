$:.unshift(File.dirname(__FILE__) + "/../lib/")

require 'test/unit'
require 'ezcrypto'
require 'base64'

class EzCryptoTest < Test::Unit::TestCase

  def setup
  end

  def test_generate_alg_key
    assert_generate_alg_key "aes-128-cbc",16
    assert_generate_alg_key "aes-192-cbc",24
    assert_generate_alg_key "aes-256-cbc",32    
    assert_generate_alg_key "rc2-40-cbc",5 
    assert_generate_alg_key "rc2-64-cbc",8
    assert_generate_alg_key "rc4-64" ,8
    assert_generate_alg_key "blowfish" ,16
    assert_generate_alg_key "des" ,8
  end
  
  def test_with_password
      assert_with_password "","secret","aes-128-cbc",16
      assert_with_password "test","secret","aes-128-cbc",16
      assert_with_password "password","secret","aes-128-cbc",16
      assert_with_password "aæsldfad8q5æ34j2æl4j24l6j2456","secret","aes-128-cbc",16
      
      assert_with_password "","secret","aes-192-cbc",24
      assert_with_password "test","secret","aes-192-cbc",24
      assert_with_password "password","secret","aes-192-cbc",24
      assert_with_password "aæsldfad8q5æ34j2æl4j24l6j2456","secret","aes-192-cbc",24

      assert_with_password "","secret","aes-256-cbc",32
      assert_with_password "test","secret","aes-256-cbc",32
      assert_with_password "password","secret","aes-256-cbc",32
      assert_with_password "aæsldfad8q5æ34j2æl4j24l6j2456","secret","aes-256-cbc",32

  end

  def test_encoded
    0.upto 32 do |size|
      assert_encoded_keys size
    end
  end
  
  def test_encrypt    
    0.upto(CLEAR_TEXT.size-1) do |size|
      assert_encrypt CLEAR_TEXT[0..size]
    end  
  end
  
  def test_decrypt
    
    0.upto(CLEAR_TEXT.size) do |size|
      assert_decrypt CLEAR_TEXT[0..size]
    end  
  end

  def test_decrypt64
    0.upto(CLEAR_TEXT.size) do |size|
      assert_decrypt64 CLEAR_TEXT[0..size]
    end  
  end

  def assert_key_size(size,key)
    assert_equal size,key.raw.size      
  end
  
  def assert_generate_alg_key(algorithm,size)
    key=EzCrypto::Key.generate :algorithm=>algorithm
    assert_key_size size,key 
  end
 
  def assert_with_password(password,salt,algorithm,size)
    key=EzCrypto::Key.with_password password,salt,:algorithm=>algorithm
    assert_key_size size,key
    assert_equal key.raw,EzCrypto::Key.with_password( password,salt,:algorithm=>algorithm).raw
  end
  
  def assert_encoded_keys(size)
    key=EzCrypto::Key.generate size
    key2=EzCrypto::Key.decode(key.encode)
    assert_equal key.raw, key2.raw    
  end
  
  def assert_encrypt(clear)
    ALGORITHMS.each do |alg|
      key=EzCrypto::Key.generate :algorithm=>alg
      encrypted=key.encrypt clear
      assert_not_nil encrypted    
    end
  end
  
  def assert_decrypt(clear)
    ALGORITHMS.each do |alg|
      key=EzCrypto::Key.generate :algorithm=>alg
      encrypted=key.encrypt clear
      assert_not_nil encrypted
      assert_equal clear,key.decrypt(encrypted)
    end
  end
  def assert_decrypt64(clear)
    key=EzCrypto::Key.generate
    encrypted=key.encrypt64 clear
    assert_not_nil encrypted
    assert_equal clear,key.decrypt64(encrypted)
  end
  ALGORITHMS=["aes128","bf","blowfish","des","des3","rc4","rc2"]
  CLEAR_TEXT="Lorem ipsum dolor sit amet, suspendisse id interdum mus leo id. Sapien tempus consequat nullam, platea vitae sociis sed elementum et fermentum, vel praesent eget. Sed blandit augue, molestie mus sed habitant, semper voluptatibus neque, nullam a augue. Aptent imperdiet curabitur, quam quis laoreet. Dolor magna. Quis vestibulum amet eu arcu fringilla nibh, mi urna sunt dictumst nulla, elit quisque purus eros, sem hendrerit. Vulputate tortor rhoncus ac nonummy tortor nulla. Nunc id nunc luctus ligula."
end

