variable "csv_file" {
  description = "Path to the CSV file containing parameters"
  default     = "Infra-parameters.csv"
}

locals {
  csv_data = csvdecode(file(var.csv_file))
  workspace_name = local.csv_data[0].workspace_name
  automation_account_name = local.csv_data[0].automation_account_name
  metric_dcr_name = local.csv_data[0].metric_dcr_name
  Infra_RG_name = local.csv_data[0].Infra_RG_Name
  Infra_RG_location = local.csv_data[0].Infra_RG_location
  AG_name = local.csv_data[0].AG_name
  vault_name = local.csv_data[0].vault_name
  backup_policy_name = local.csv_data[0].backup_policy_name
  CT_DCR_name = local.csv_data[0].CT_DCR_name
  VM_RG_Name = local.csv_data[0].VM_RG_Name
  VM_RG_Location = local.csv_data[0].CT_DCR_Location
  VM_Name = local.csv_data[0].VM_Name
}