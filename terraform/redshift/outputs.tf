output "cluster_endpoint" {
    value = "${aws_redshift_cluster.cluster.endpoint}"
}