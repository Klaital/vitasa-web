namespace :maintenance do
  desc "Dump the current database, replace it with what's in production"
  task export: :environment do
    filename = File.join(Rails.root, "#{Rails.env}.sql.gz")
    db_config = current_db_config(Rails.env)
    system "#{mysqldump(db_config)} | gzip -c > #{filename}"
  end

  desc "Import a database"
  task import: :environment do
    filename = ENV['FILE']
    raise "Need a FILE" unless file
    raise "I refuse to blow away production" if Rails.env.production?
    db_config = current_db_config(Rails.env)
    system "gzip -d -c #{filename} | #{mysql(db_config)}"
  end

  desc "Update the container"
  task build: :environment do
    puts "Authenticating with ECR..."
    login_cmd = `aws ecr get-login --no-include-email --region us-west-2`
    `#{login_cmd}`
    puts "Building image..."
    `docker build -t 813809418199.dkr.ecr.us-west-2.amazonaws.com/vitasa-web:latest .`
    puts "Uploading build..."
    `docker push 813809418199.dkr.ecr.us-west-2.amazonaws.com/vitasa-web:latest`
  end

  def current_db_config(env)
    YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'database.yml'))).result)[env]
  end

  def mysql(config)
    sql_cmd("mysql", config)
  end

  def mysqldump(config)
    sql_cmd("mysqldump", config) + " --add-drop-table --extended-insert=TRUE --disable-keys --complete-insert=FALSE --triggers=FALSE"
  end

  def sql_cmd(sql_command, config)
    "".tap do |cmd|
      cmd << sql_command
      cmd << " "
      cmd << "-u#{config["username"]} " if config["username"]
      cmd << "-p#{config["password"]} " if config["password"]
      cmd << "-h#{config["host"]} " if config["host"]
      cmd << "-P#{config["port"]} " if config["port"]
      cmd << "--default-character-set utf8 "
      cmd << config["database"] if config["database"]
    end
  end
end
