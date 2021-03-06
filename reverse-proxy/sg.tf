# -----------------------------------------------------------------------------
# Security Group public access (load balancer)
# -----------------------------------------------------------------------------
resource "aws_security_group" "rp_lb" {
    name        = "${var.service}-reverse-proxy-${var.environment}-lb-sg"
    description = "Reverse Proxy Security Group HTTP and HTTPS access"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.service}-reverse-proxy-${var.environment}-lb-sg"
        Service     = var.service
        Environment = var.environment
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_security_group_rule" "lb_http_ingress" {
    from_port         = 80
    protocol          = "tcp"
    security_group_id = aws_security_group.rp_lb.id
    to_port           = 80
    type              = "ingress"
    cidr_blocks       = [
        var.everyone]
}

resource "aws_security_group_rule" "lb_http_egress" {
    security_group_id = aws_security_group.rp_lb.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [
        var.everyone]
}

resource "aws_security_group_rule" "lb_https_ingress" {
    from_port         = 443
    protocol          = "tcp"
    security_group_id = aws_security_group.rp_lb.id
    to_port           = 443
    type              = "ingress"
    cidr_blocks       = [
        var.everyone]
}

# -----------------------------------------------------------------------------
# Security group reverse proxy instance
# - allowing ports 22, 53 and 80
# -----------------------------------------------------------------------------
resource "aws_security_group" "rp" {
    name        = "${var.service}-reverse-proxy-${var.environment}-sg"
    description = "Reverse proxy security group"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.service}-reverse-proxy-${var.environment}-sg"
        Service     = var.service
        Environment = var.environment
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_security_group_rule" "rp_http_ingress" {
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_group_id        = aws_security_group.rp.id
    type                     = "ingress"
    source_security_group_id = aws_security_group.rp_lb.id
}

resource "aws_security_group_rule" "rp_ssh_ingress" {
    from_port                = 22
    to_port                  = 22
    protocol                 = "tcp"
    security_group_id        = aws_security_group.rp.id
    type                     = "ingress"
    source_security_group_id = aws_security_group.rp_lb.id
}

resource "aws_security_group_rule" "rp_vpn_ingress" {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    security_group_id = aws_security_group.rp.id
    type              = "ingress"
    cidr_blocks       = [
        var.vpn_cidr]
}

resource "aws_security_group_rule" "rp_on_prem_ingress" {
    from_port         = 1024
    to_port           = 65535
    protocol          = "tcp"
    security_group_id = aws_security_group.rp.id
    type              = "ingress"
    cidr_blocks       = var.on_prem_cidrs
}

resource "aws_security_group_rule" "rp_egress" {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    security_group_id = aws_security_group.rp.id
    type              = "egress"
    cidr_blocks       = [
        var.everyone]
}

# -----------------------------------------------------------------------------
# Security group reverse proxy EFS
# -----------------------------------------------------------------------------
resource "aws_security_group" "rp_efs" {
    name        = "${var.service}-efs-reverse-proxy-${var.environment}-sg"
    description = "Reverse proxy EFS storage security group"
    vpc_id      = var.vpc_id

    tags = {
        Name        = "${var.service}-efs-reverse-proxy-${var.environment}-sg"
        Service     = var.service
        Environment = var.environment
        CostCentre  = var.cost_centre
        Owner       = var.owner
        CreatedBy   = var.created_by
        Terraform   = true
    }
}

resource "aws_security_group_rule" "rp_efs_ingress" {
    from_port                = 0
    protocol                 = "tcp"
    security_group_id        = aws_security_group.rp_efs.id
    to_port                  = 65535
    type                     = "ingress"
    source_security_group_id = aws_security_group.rp.id
}

resource "aws_security_group_rule" "rp_efs_egress" {
    security_group_id = aws_security_group.rp_efs.id
    type              = "egress"
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = [
        var.everyone]
}
