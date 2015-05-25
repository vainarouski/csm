require "time"

module TestReportWriter


  def html_builder(test_report)

    html_report = <<-EOS
        <html>
    EOS

    html_style = <<-EOS
          <style>
            body {background-color: #FFFFF0; font-family: "VAG Round" ; color : #000080;font-weight:normal;word-break: break-all;}

            #specifications{font-family:Arial,Helvetica,Sans-serif;font-size:13px;width:480px;background:#fff;border-collapse:collapse;text-align:left;margin:20px;border:1px solid #ccc;}
            #specifications th{font-size:14px;font-weight:bold;color:#039;border-bottom:2px solid #6678b1;padding:10px 8px;text-align: center;}
            #specifications td{border-bottom:1px solid #ccc;color:#009;padding:6px 8px;}

            #statuspass{font-family:Arial,Helvetica,Sans-serif;font-size:12px;color:green;font-weight:bold;}
            .statusfail{font-family:Arial,Helvetica,Sans-serif;font-size:12px;color:red;font-weight:bold;text-align: center;}

            #tcs{font-family:Arial,Helvetica,Sans-serif;font-size:13px;background:#fff;width:1050px;border-collapse:collapse;text-align:left;margin:20px;border:1px solid #ccc;}
            #tcs th{font-size:14px;font-weight:bold;color:#039;border-bottom:2px solid #6678b1;padding:10px 8px;text-align: center;}
            #tcs td{border-bottom:1px solid #ccc;color:#009;padding:6px 8px;white-space: nowrap;}

            #checkpoint{font-family:Arial,Helvetica,Sans-serif;font-size:13px;background:#fff;width:1050px;border-collapse:collapse;text-align:left;margin:20px;border:1px solid #ccc;}
            #checkpoint td{border-bottom:1px solid #ccc;color:#009;padding:6px 8px;}
            #container{margin: 0 30px;background: #fff;border:1px solid #ccc;}
            #header{background: #e8edff;padding: 2px;border-bottom: 2px solid #6678b1;}
            #steps{background: #e8edff;font-weight: bold;}
            #dp{font-weight: bold;}
            #validations{font-weight: bold;}
            #content{clear: left;padding: 10px;}
            #footer{background: #e8edff;text-align: right;padding: 10px;}
          </style>
    EOS

    title = <<-EOS
        <head><title>Common Sense Media JSON test</title></head>
        <body>
        <center>
    EOS

    html_report += html_style + title

    test_suite_time_in_secs = Time.now - test_report[:start_time]

    report_header = <<-EOS
    <h1><u>Common Sense Media JSON test<\/u><\/h1><br\/>
        <h4>Test summary:</h4>
        <table id="specifications" width="900px">
          <tr><td>Test started On: #{test_report[:start_time]}</td></tr>
          <tr><td>Duration: #{test_suite_time_in_secs} secs</td></tr>
          <tr><td>Items tested: #{test_report.size - 1}</td></tr>
        </table>

    EOS

    report_tc_summary = <<-EOS
          <h4>Test results:</h4>
          <table id="tcs">
            <tr>
            <th>#</th>
            <th>id</th>
            <th>Test Property Name</th>
            <th>Error Message</th>
            <th class="result_field">Result</th>
            </tr>
    EOS

    index = 1
    test_report.each do |tc_id, tc|
       next if tc_id == :start_time || tc.length == 0
      tc.each do |error_message|
      report_tc_summary += <<-EOS
            <tr>
            <td>#{index.to_s.rjust(3,'0')}</td><td>#{tc_id}</td><td>#{error_message[:property]}</td><td>#{error_message[:message]}</td><td><font class="statusfail">FAIL</font></td>
            </tr>
      EOS
        index += 1
      end
    end

     report_footer = <<-EOS
          </table>
          </center>
          </body>
          </html>
    EOS

    html_report += report_header + report_tc_summary + report_footer

    html_report

  end

end