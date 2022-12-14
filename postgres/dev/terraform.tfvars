vpc_name = "backend-mysql"
backend_region = "eu-west-1"
owner = "user"
environment = "dev"
vpc_cidr = "10.99.0.0/18"
vpc_azs = ["${local.region}a", "${local.region}b", "${local.region}c"]
vpc_public_subnets = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
vpc_private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
vpc_database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]
sg_ingress_port = 3306
sg_ingress_protocol = "tcp"
db_identifier = "demodb"
db_engine = "mysql"
db_engine_version = "8.0.27"
db_family = "mysql8.0"
db_major_engine_version = "8.0"
db_instance_class = "db.t4g.large"
db_allocated_storage = 20
db_max_allocated_storage = 100
db_name = "Ray_Demo"
db_username = "rayliu25"
db_port = "3306"
db_maintenance_window = "Mon:00:00-Mon:03:00"
db_backup_window = "03:00-06:00"
db_monitoring_interval = "30"
db_monitoring_role_name = "MyRDSMonitoringRole"
db_create_monitoring_role = true