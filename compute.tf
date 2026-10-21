
resource "aws_launch_template" "app" {
  name        = "${var.project_name}-app-launch-template"
  description = "Version 2 - Node.js with secure PostgreSQL RDS integration"

  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  credit_specification {
    cpu_credits = "standard"
  }

  # Create a new Launch Template version.
  # Do not make it the default until we test it.
  update_default_version = false

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -euo pipefail

    BUCKET="${aws_s3_bucket.app_artifacts.bucket}"
    PACKAGE="project1-app-v3-bundled.tar.gz"
    APP_DIR="/home/ssm-user/project1-app"
    NEXT_DIR="/home/ssm-user/project1-app-next"

    # Download application from our private S3 bucket
    aws s3 cp \
      "s3://$BUCKET/releases/$PACKAGE" \
      "/tmp/$PACKAGE" \
      --region "${var.aws_region}"

    # Unpack the application and its dependencies
    mkdir -p "$NEXT_DIR"
    tar -xzf "/tmp/$PACKAGE" -C "$NEXT_DIR"

    test -f "$NEXT_DIR/index.js"
    test -d "$NEXT_DIR/node_modules"

    chown -R ssm-user:ssm-user "$NEXT_DIR"

    # Prepare the existing application service
    systemctl stop project1-app.service

    if [ -d "$APP_DIR" ]; then
      mv "$APP_DIR" "/home/ssm-user/project1-app-original"
    fi

    mv "$NEXT_DIR" "$APP_DIR"

    systemctl enable project1-app.service
    systemctl start project1-app.service

    # Confirm the application responds
    for attempt in 1 2 3 4 5 6 7 8 9 10 11 12; do
      if curl --fail --silent \
        http://127.0.0.1:3000/health > /dev/null; then
        echo "PROJECT1_APP_READY"
        exit 0
      fi
      sleep 5
    done

    echo "PROJECT1_APP_STARTUP_FAILED" >&2
    exit 1
  USERDATA
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app-server"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.project_name}-app-asg"

  min_size         = var.asg_min_size
  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size

  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "3"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-srver"
    propagate_at_launch = true
  }
}
