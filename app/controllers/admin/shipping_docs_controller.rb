require 'csv'

class Admin::ShippingDocsController < Admin::BaseController
  include Admin::ShippingDocsHelper

  def index

    date_end = Time.new
    date_start = date_end - (60 * 24 * 7)

    # parse date according to locale setting
    if !params[:start].blank?
      date_start = Time.zone.parse(params[:start]).beginning_of_day rescue ""
    end

    if !params[:end].blank?
        date_end = Time.zone.parse(params[:end]).end_of_day rescue ""
    end

    @orders = Order.find(:all, :conditions => { :completed_at => date_start..date_end, :state => 'complete', :shipment_state => 'pending', :wholesale => false })

    csv_string = CSV.generate do |csv|

        # header row
        csv << csv_header_row
      
        # data rows
        @orders.each do |order|
            csv <<  csv_order_row(order)
        end

    end

    # send it to the browsah
    send_data csv_string,
        :type => 'text/csv; charset=iso-8859-1; header=present',
        :disposition => "attachment; filename=users.csv"
  end

end

