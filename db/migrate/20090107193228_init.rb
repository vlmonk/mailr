class Init < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :fname, :lname, :email
      t.integer :customer_id
      t.timestamps
    end

    create_table :filters do |t|
      t.string :name, :destination_folder
      t.integer :customer_id, :order_num
      t.timestamps
    end

    create_table :expressions do |t|
      t.string :field_name, :operator, :expr_value
      t.integer :filter_id
      t.boolean :case_sensitive
      t.timestamps
    end

    create_table :mail_prefs do |t|
      t.string :mail_type
      t.integer :wm_rows, :default => 20
      t.integer :customer_id
      t.boolean :check_external_mail
      t.timestamps
    end

    create_table :contacts do |t|
      t.string :fname, :lname, :email, :hphone, :wphone, :mobile, :fax
      t.text :notes
      t.integer :customer_id
      t.timestamps
    end

    create_table :contact_groups do |t|
      t.string :name
      t.integer :customer_id
      t.timestamps
    end

    create_table :contact_contact_groups do |t|
      t.integer :contact_id, :contact_group_id
      t.timestamps
    end

    create_table :imap_messages do |t|
      t.string :folder_name, :username, :msg_id, :from, :from_flat, :to, :to_flat, :subject, :content_type
      t.integer :uid, :size
      t.boolean :unread
      t.datetime :date
    end
  end

  def self.down
    drop_table :imap_messages
    drop_table :contact_contact_groups
    drop_table :contact_groups
    drop_table :contacts
    drop_table :mail_prefs
    drop_table :expressions
    drop_table :filters
    drop_table :customers
  end
end
