resource "aws_guardduty_detector" "primary" {
  enable = true
  count  = "${var.count}"
}
