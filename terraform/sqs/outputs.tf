output "sqs_arn" {
  value = "${aws_sqs_queue.main_queue.arn}"
}