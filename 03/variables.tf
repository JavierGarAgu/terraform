# Generate a random integer resource named "ri" with minimum value 10000 and maximum value 99999
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Define a variable named "servername" of type string with a default value of "jga"
variable "servername" {
  type    = string
  default = "jga"
}

# Define a variable named "database" of type string with a default value of "coches"
variable "database" {
  type    = string
  default = "coches"
}

# Define a variable named "user" of type string with a default value of "jga"
variable "user" {
  type    = string
  default = "jga"
}

# Define a variable named "password" of type string with a default value of "1234!Strong"
variable "password" {
  type    = string
  default = "1234!Strong"
}
