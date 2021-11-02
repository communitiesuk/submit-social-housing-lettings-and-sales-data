ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Case Logs" do
          table_for CaseLog.order(updated_at: :desc).limit(10) do
            column :id
            column :created_at
            column :updated_at
            column :status
            column :tenant_code
            column :property_postcode
          end
        end
      end

      column do
        panel "Total case logs in progress" do
          para CaseLog.in_progress.size
        end
        panel "Total case logs completed" do
          para CaseLog.completed.size
        end
      end
    end
  end
end
