# -*- encoding: utf-8

module DataLoader
  class ErrorPoint
    include DataMapper::Resource
    storage_names[:default] = 'error_points'

    # t9t10 --> the circuit that was scanned...in the case, all will be t9t10 (a string)
    # high --> laser pulse energy (also a string)
    # 1012 --> the pixel number...when in the scan the file was made (int)
    # avg1 --> the scan number as: avg#. In this case it's always integers 1-5.

    property :id,           Serial
    property :circuit,      String, :required => true, :index => true
    property :time,         Float, :required => true, :index => true
    property :voltage,      Float, :required => true, :index => true
    property :strike_point, Float, :required => true
    property :strike_delta, Float, :required => true
    property :energy,       String
    property :pixel,        Integer, :index => true
    property :scan,         String, :index => true
    property :type,         String, :index => true
  end
end
