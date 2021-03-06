resource "aws_instance" "rp_primer" {
    ami                         = var.ami_id
    associate_public_ip_address = var.public_ip
    instance_type               = var.instance_type
    key_name                    = var.key_name
    subnet_id                   = var.subnet_id
    iam_instance_profile        = aws_iam_instance_profile.primer_rp_profile.name
    vpc_security_group_ids      = [
        aws_security_group.rp.id
    ]

    root_block_device {
        volume_size = var.volume_size
        encrypted   = true
    }

    user_data = templatefile("${path.module}/scripts/userdata.sh", {
        s3_deployment_bucket = var.s3_deployment_bucket,
        s3_deployment_root   = var.s3_deployment_root,
        s3_logfile_bucket    = var.s3_logfile_bucket,
        s3_logfile_root      = var.s3_logfile_root,
        service              = var.tags.Service,
        ssm_download_region  = var.ssm_download_region
    })

    tags = merge(var.tags, {
        Name = var.instance_name
    })
}
