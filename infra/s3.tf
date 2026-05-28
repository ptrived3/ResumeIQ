resource "aws_s3_bucket" "resumeiq" {   // Define an S3 bucket resource named "resumeiq"
    bucket = "resumeiq-bucket-prachi"    // Specify the name of the S3 bucket

    tags = {    // Add tags to the S3 bucket for better organization and management
        Project = "ResumeIQ"
    }
}

// Define a resource to enable versioning for the S3 bucket
// versioning allows you to keep multiple versions of an object in the same bucket, 
    // which can help with data recovery and protection against accidental deletion or overwriting.
resource "aws_s3_bucket_versioning" "resumeiq" {    
    bucket = aws_s3_bucket.resumeiq.id  // Reference the S3 bucket created above using its ID

    versioning_configuration{
        status = "Enabled" // Enable versioning for the S3 bucket
    }
}

// Define a resource to enable server-side encryption for the S3 bucket
// Server-side encryption helps protect data at rest by encrypting the objects stored in the bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "resumeiq" {
    bucket = aws_s3_bucket.resumeiq.id  // Reference the S3 bucket created above using its ID

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256" // Use AES-256 encryption algorithm for server-side encryption
        }
    }
}