#install.packages(c("tidyr", "reshape2"), dependencies = T)
sapply(c("tidyr", "reshape2", "magrittr"), require, character.only = T)

#+++++++++++++++++++++++++++++++++++++++++++++++
# 2 Các tình huống tổng hợp và xử lý dữ liệu
#+++++++++++++++++++++++++++++++++++++++++++++++

##2.1 Gộp dữ liệu theo trục (unpivot table)
  #Khái niệm gộp dữ liệu theo trục là việc gộp và tổng hợp dữ liệu của nhiều cột dữ liệu vào 
  #thành một cột chung chứa giá trị của các cột này hoặc giá trị tổng hợp từ các cột này.
  #Một trong những lợi ích lớn nhất của việc gộp dữ liệu theo trục là hỗ trợ người phân tích 
  #dữ liệu trong việc vẽ đồ thị. Nếu bạn đã sử dụng gói ggplot2 để vẽ đồ thì, bạn sẽ thấy việc gộp
  #dữ liệu là điều bạn cần làm trước khi vẽ bất kỳ đồ thị nào. Trong gói tidyr, chúng ta có hàm gather(), 
  #còn trong gói reshape2 chúng ta có hàm melt(). Tính năng và ứng dụng của 2 hàm này phụ thuộc vào
  #mục đích sử dụng của người dùng.
  
  #Giả sử chúng ta có dữ liệu về điểm số của sinh viên như sau:
  # Tạo dữ liệu sample
  StudentID <- c("1004", "1897", "1234", "1123", "1345", "1542", "1236", "7894", "6548", "7894")
  Name <- c("Nam", "Hai", "Long", "Nguyet", "Nhat", "Nhung", "Huyen", "Duc", "Vu", "Giang")
  Gender <- c("M", "F", "M", "F", "F", "F", "F","M", "M", "M")
  English <- c(9, 8, 5, 7.5, 6, 6.5, 8.3, 4.5, 10, 5)
  Maths <- c(10, 9, 8.9, 7, 6, 9.7, 7.8, 8.7, 7, 7.5)
  History <- c(8, 7, 6, 5, 8.9, 6.5, 8.5, 7.2, 8.9, 9)
  Status <- c("P", "P", "F", "F", "P", "P","P", "F", "P", "F")
  score <- data.frame(StudentID, Name, Gender, English, Maths, History, Status)

  #Bây giờ chúng ta chỉ muốn tổng hợp dữ liệu về điểm số của sinh viên thành một cột dữ liệu theo từng sinh viên, 
  #và có một cột dữ liệu về tên môn học để nhận biết điểm của môn nào, chúng ta có thể dùng hàm gather() của gói tidyr. 
 
   #Hàm gather() có cấu trúc: gather(data, key, value, …), trong đó:
    #data: bảng dữ liệu cần gộp
    #key: cột dữ liệu mới được tạo ra để lưu tên các cột được gộp
    #value: cột dữ liệu mới được tạo ra để lưu giá trị của các cột được gộp tương ứng
    #…: chi tiết tên các cột được gộp.

  #Với cấu trúc trên, hày cùng nhau gộp dữ liệu score:
  score_gather <- score %>%
    gather(key = "Subject" # đặt tên cột chứa các môn học là Subject
           , value = "Score" # đặt tên cột chứa giá trị điểm các môn là Score
           , c(English, Maths, History) # liệt kê các cột được gộp với nhau
    )
  score_gather

  library(ggplot2)
  score_gather %>%
    ggplot(aes(StudentID, Score)) + 
    geom_bar(aes(fill = Subject), stat = "identity", position = "dodge")

  #Như vậy thông tin về điểm thi đã được gộp với nhau để tiện cho việc quan sát cũng như vẽ đồ thị.
  #Tương tự như hàm gather(), hàm melt() trong gói reshape2 cũng làm công việc tương tự. 
  
  #Hàm melt() có cấu trúc: melt(data, id.vars, measure.vars, variable.name = “variable”, value.name, …), trong đó:
    #data: bảng dữ liệu cần gộp
    #id.vars: là vector của các cột dữ liệu được giữ nguyên
    #measure.vars: là vector của các cột được gộp
    #variable.name: là tên của cột được sử dụng để lưu tên các cột được gộp
    #value.name: laf tên của cột lưa giá trị của các cột được gộp

  score_melt <- score %>%
    melt(id.vars = c("StudentID", "Name", "Gender", "Status") # các cột này được giữ nguyên
         , measure.vars = c("English", "Maths", "History") # các cột được gộp với nhau
         , variable.name = "Subject"
         , value.name = "Score"
    )
  score_melt

  #Có thể thấy score_melt và score_gather không khác nhau về cấu trúc và giá trị các ô dữ liệu. Hai hàm gather() và melt() 
  #đều trả về giá trị giống nhau nhưng cấu trúc có phần khác biệt nhau. Bạn có thể thấy hàm melt() có cấu trúc 
  #chi tiết hơn so với hàm gather(). Tuy nhiên, với cách thức của hàm melt() cho ta sự lựa chọn trong việc nhặt 
  #chi tiết các trường dữ liệu được giữ nguyên (chiều thông tin). Chỉ các trường thông tin được chọn này sẽ được 
  #lưu lại trên bảng dữ liệu mới.

  #Ví dụ khác: sử dụng dữ liệu iris, gộp các trường thông tin về chiều dài và chiều rộng của đài hoa và cánh hoa, 
  #đặt tên các thông tin này là Indicator còn cột lưu số liệu là Value:
  head(iris)

  iris %>%
    gather("Indicator", "Value", -Species) %>%
    head

  iris %>%
    melt(id.vars = "Species", measure.vars = c("Sepal.Length", "Petal.Length", "Sepal.Width", "Petal.Width"), variable.name = "Indicator", value.name = "Value") %>%
    head

  #Trong R base chúng ta có thể dùng hàm stack() để thực hiện công việc trên. Tuy nhiên, nếu chỉ thực hiện với hàm stack, 
  #chung ta sẽ nhận được kết quả không được như mong muốn do stack() chỉ hỗ trợ gộp các cột dữ liệu lại với nhau:
  score %>%
    stack(select = c("English", "History", "Maths"))

  #Đây chắc chắn không phải là kết quả mà bạn mong muốn. Để được kết quả tương tự như hàm melt() hoặc gather() đã làm, 
  #chúng ta sẽ kết hợp với hàm cbind() với stack() để thực hiện công việc trên:
  score %>%
    stack(select = c("English", "History", "Maths")) %>%
    cbind(score[, c("StudentID", "Name", "Gender", "Status")])

##2.2 Xoay dữ liệu theo trục (pivot table)
  #Khái niệm xoay dữ liệu theo trục có thể rất quen thuộc với nhiều bạn đọc, đặc biết với những ai đã và đang sử
  #dụng Excel với pivot table. Xoay dữ liệu theo trục cho phép người dùng có thể nhìn dữ liệu theo nhiều sâu với 
  #cách thức tổng hợp dữ liệu khác nhau như: số lượng, tổng giá trị, giá trị bình quân, giá trị lớn nhất, nhỏ nhất…
  #Trong R, với cả gói tidyr và reshape2, chúng ta có thể làm công việc tương tự với các hàm spread() và dcast() tương ứng.

  #Hàm spread() trong tidyr có cấu trúc như sau: spread(data, key, value, fill = NA, …), trong đó:
    #data: bảng dữ liệu thực hiện xoay chiều
    #key: cột dữ liệu được sử dụng để phân rã ra nhiều cột
    #value: tên của cột được sử dụng để điền các giá trị tương ứng cho các cột phân rã
    #fill: nếu không có giá trị thì sẽ được thay thế bẳng giá trị tương ứng, mặc định là NA nếu không được nêu rõ.

  #Ví dụ:
  score_gather %>%
    spread(Subject, Score)

  #Với hàm spread(), chúng ta chỉ có thể duỗi dữ liệu ra từ dạng cột sang dạng hàng khi một cột dữ liệu chứa 
  #thông tin theo chiều các môn học được duỗi ra thành nhiều cột khác nhau, từng cột mới tương ứng với từng 
  #môn học và điểm của các môn học. Nếu chúng ta muốn nhìn dữ liệu với các chỉ số khác nhau như số dư trung bình,
  #tổng số, số lượng vv… thì spread() sẽ không thể đáp ứng được những yêu cầu này. 
  #Tuy nhiên, với hàm dcast() từ gói reshape2, chúng ta có thể làm được công việc này.
  
  #Hàm dcast() có cấu trúc: dcast(data, formula, fun.aggregate = NULL, …), trong đó:
    #data: bảng dữ liệu cần xoay chiều
    #formula: công thức thực hiện xoay chiều, có 2 về và được phân tách với nhau bởi dấu ~. 
      #Vế bên tay trái là các cột được giữ nguyên. Vế tay phải là các cột được xoay trục
    #fun.aggregate: hàm đượ sử dụng để tổng hợp dữ liệu trong quá trình xoay trục như: 
      #tổng số, số lượng, số trung bình…

  #Với dữ liệu score_melt đã được xử lý vừa rồi, nếu chúng ta chỉ đơn thuần muốn duỗi dữ liệu ra 
  #thành nhiều cột mà không thực hiện việc tính toán, tổng hợp dữ liệu, thì tham số về hàm tổng hợp 
  #(fun.aggregate) sẽ không sử dụng:
  score_melt %>%
    dcast(formula = StudentID + Name + Gender + Status ~ Subject)

  #Nếu chúng ta muốn duỗi nhiều trường dữ liệu với nhau, ví dụ điểm môn + trượt/đỗ, 
  #chúng ta có thể làm bằng cách bổ sung trường vào vế tay phải của công thức (formula):
  score_melt %>%
    dcast(StudentID + Name + Gender ~ Subject + Status, fill = "")

  #Số lượng cột được sinh mới (xoay trục) sẽ là tích của số lượng các giá trị duy nhất của từng cột được xoay trục. 
  #Ở đây là 6 (3 * 2) (có 3 môn, 2 trạng thái). Trong code phía trên, chúng ta có thể dùng thêm tham số fill
  #(mặc định là NA) để điền giá trị vào cho những ô dữ liệu không có giá trị
  #(ở đây chúng ta để các giá trị này là trống - “”).

  #Giờ chúng ta muốn thực hiện việc xoay trục dữ liệu, đồng thời thực hiện các tính toán về dữ liệu như tính tổng, 
  #tổng số lượng hoặc số trunh bình, chúng ta có thể làm như sau:
  library(dplyr)
  loan <- read.csv(".../FactLoan.csv", sep = ",", header = T)
  names(loan) <- tolower(names(loan))
  loan <- distinct(loan) # lấy các dòng dữ liệu duy nhất của bảng dữ liệu

  #Tính tổng số dư chi tiết cho từng sản phẩm, theo từng chi nhánh:
  pro_sum <- loan %>%
    select(branch_id, pro_name, balance) %>% # nhặt các trường branch_id, pro_name và balance cho việc xoay trục dữ liệu   
    dcast(branch_id ~ pro_name, fun.aggregate = sum)
  head(pro_sum)
  
  #Kiểm tra lại kết quả với sản phẩm Others cho chi nhánh VN10116:
  loan %>%
    filter(branch_id == "VN10116", pro_name == "Others") %>%
    select(balance) %>%
    sum

  #Tính số lượng khách hàng chi tiết cho từng sản phẩm, theo từng chi nhánh:
  pro_count <- loan %>%
    select(cust_no, branch_id, pro_name) %>%
    dcast(branch_id ~ pro_name, length)
  head(pro_count)

  #chúng ta có thể check kết quả ở trên với 1 ví dụ nhỏ cho sản phẩm Mortgage và với chi nhánh VN10114, có 4 khách hàng:
  loan %>%
    filter(branch_id == 'VN10114', pro_name == 'Mortgage')

  #Tính số dư trung bình cho từng sản phẩm, theo từng chi nhánh:
  pro_mean <- loan %>%
    select(branch_id, pro_name, balance) %>%
    dcast(branch_id ~ pro_name, mean)
  head(pro_mean)

  #Chúng ta cũng có thể tính các giá trị khác như: độ lệch chuẩn(sd); phương sai (vars);
  #giá trị lớn nhất-nhỏ nhất (max-min)…

  #lưu ý: hàm dcast mặc định fun.aggregate là hàm length() nếu trong tình huống mà tham số
  #fun.aggregate không được bổ sung trong hàm.
  
##2.3 Bổ sung dữ liệu trống/giá trị trắng (NA)
  #Trong quá trình tổng hợp dữ liệu, nhiều trường hợp dữ liệu tổng hợp bị trống hoặc trắng 
  #do dữ liệu không có hoặc dữ liêu đầu vào bị thiếu. Như ví dụ ở trên khi chúng ta tính toán 
  #số dư trung bình của các sản phẩm cho vay theo chi nhánh sẽ có một số sản phẩm không bán được 
  #tại chi nhánh nào đó, khiến số liệu đưa ra bị NA. Tuy nhiên, chúng ta lại không muốn để NA và muốn thay thế bằng giá trị nào đó thích hợp với hoàn cảnh. Để làm được việc này, chúng ta sẽ dùng một trong 2 hàm replace_na() trong gói tidyr.

  #Giả sử chúng ta muốn thay thế giá trị NA bằng 0, chúng ta có thể làm như sau:
  loan %>%
    select(branch_id, pro_name, balance) %>%
    dcast(branch_id ~ pro_name, mean) %>%
    replace_na(list(Auto = 0, Others = "Khong gia tri")) %>%
    head
  
  #Với hàm replace_na(), chúng ta phải liệt kê các trường cần thay thế giá trị NA 
  #bằng một list(danh sách các cột cần thay thế). Các trường thông tin còn lại không nằm trong 
  #list() này sẽ không được thay thế.
  
##2.4 Tách và gộp các cột dữ liệu với nhau
  #Rất nhiều khi trong quá trình tổng hợp dữ liệu, chúng ta muốn tách một cột dữ liệu ra thành 
  #nhiều cột dữ liệu hoặc ngược lại muốn gộp nhiều trường dữ liệu lại với nhau thành một cột 
  #dữ liệu duy nhất. Để thực hiện việc tách một trường dữ liệu ra thành nhiều trường, chúng ta sẽ dùng
  #hàm separate() trong gói tidyr hoặc hàm colsplit() trong gói reshape2. Có sự khác biệt nhất định giữa
  #2 hàm này, chúng ta sẽ đi chi tiết ở dưới. 
  
  #Hàm separate() có cấu trúc: separate(data, col, into, sep = “[^[:alnum:]]+”, …), trong đó:
    #data: bảng dữ liệu có cột cần tách
    #col: tên cột dữ liệu cần tách
    #into: vector tên các cột mới sẽ được tạo ra từ cột bị tách
    #sep: ký tự đặc biệt dùng để tách cột

  #lưu ý: ký tự đặc biệt dùng để tách là ký tự có trong cột cần tách, người dùng hiểu đây chính là ký
  #tự ngăn cách các nhóm giá trị cần tách trong cột dữ liệu ban đầu. Từng nhóm ký tự này sẽ trở thành 
  #các cột dữ liệu mới sau khi được tách ra sử dụng hàm separate().

  #Ví dụ:
  score_new <- data.frame(StudentInfo = paste(StudentID, Name, Gender, sep = "#"), English, History, Maths)
  score_new %>%
    separate(StudentInfo, into = c("StudentID", "Name", "Gender"), sep = "#")

  #Tình huống trên là tương đối đơn giản khi các trước thông tin được ngăn cách với nhau bằng một ký tự 
  #đặc biệt duy nhất. Trên thực tế, khi bạn tiếp xúc với nhiều loại dữ liệu sẽ không thể trách việc các 
  #trường dữ liệu được ngăn cách với nhau bằng nhiều ký tự khác nhau hoặc trường thông tin chưa nhiều hơn 
  #thôn tin mà bạn cần… Ví dụ sau là một trong những trường hợp đó.
  
  Phone <- paste("091", (rnorm(10, 1, 10)  * 123456) %>% round(0) %>% abs, sep = "")
  score_new1 <- data.frame(StudentInfo = paste(StudentID, Name, sep = "-") %>% paste(paste(Gender, Phone, sep = ""), sep = "#")
                           , English
                           , History
                           , Maths)
  head(score_new1)

  #Trong ví dụ này, dữ liệu về sinh viên có hơn 2 ký tự đặc biệt ngăn cách các cột dữ liệu và có thểm thông tin 
  #về số điện thoại của sinh viên nhưng lại không có ngăn cách giữa số đt và giới tính của sinh viên. 
  #Để tách được dữ liệu như mong muốn, chúng ta sẽ làm như sau:
  score_new1 %>%
    separate(StudentInfo, into = c("StudentID", "Name", "Gender"), sep = "[-#]") %>%
    separate(Gender, into = "Gender_New", sep = "[[:digit:]]+")

  #Diễn giải: Trong ví dụ này, chúng ta phải thực hiện việc tách trường dữ liệu thành 2 lần, 
  #trong đó, lần 1 chúng ta tách ra thành 3 cột: StudentID, Name, Gender, các cột này được ngăn 
  #cách với nhau bằng ký tự “-” hoặc “#”. Các ký tự “[-#]” có nghĩa là “-” hoặc “#”. 
  #Sau đó, chúng ta tiếp tục tách trường Gender ra để chỉ lấy ký tự chữ của cột này bằng cách 
  #loại bỏ toàn bộ ký tự số. Chuỗi ký tự “[[:digit:]]+” có nghĩa là chuối các ký tự dạng số (digit) 
  #và có số lượng ký tự không giới hạn và > 1. Chúng ta sẽ đi qua các ký tự này với bài viết về xử lý dữ liệu dạng chữ.

  #Trong gói reshape2 chúng ta cũng có thể dùng hàm colsplit() với cấu trúc: colsplit(string, pattern, names), trong đó:
    #string: vector các ký tự cần tách
    #pattern: ký tự ngăn cách
    #names: vector tên của các cột mới

  #Các bạn có thể thấy sự khác biệt khá lớn giữa separate() và colsplit() ở đây chính là dữ liêu đầu vào của hàm. 
  #Với separate() thì dữ liệu đầu vào là bảng dữ liệu, trong đó, colsplit() sẽ là vector ký tự, 
  #hay chính là cột dữ liệu cần tách. Như vậy colsplit() sẽ kếm linh động hơn so với separate(). 
  #Với colsplit(), chúng ta có thể tách score_new như sau:
  colsplit(string = score_new$StudentInfo, pattern = "#", names = c("StudentID", "Name", "Gender")) %>% 
    cbind(score_new[, -1]) # gộp với các cột còn lại (khác cột StudentInfo) để lấy được dữ liệu đầy đủ

  #Hàm colsplit sẽ thích hợp với vector ký tự hơn do đặc tính dữ liệu đầu vào của hàm. 
  #Trong khí đó, separate() có thể linh động hơn và được dùng nhiều cho dữ liệu dạng bảng biểu.

  #Trong tình huống ngược lại, nhiều khi bạn sẽ muốn gộp các trường thông tin lại với nhau thành một 
  #cột dữ liệu chung. Để làm được việc này, chúng ta sẽ sử dụng hàm unite() trong gói tidyr. 
  
  #Hàm unite() có cấu trúc: unite(data, col, …, sep = “_“, remove = TRUE), trong đó:
    #data: bảng dữ liệu cần gộp các trường lại với nhau
    #col: tên trường dữ liệu mới sau khi gộp các trường lại với nhau
    #…: tên các cột dữ liệu cần gộp với nhau
    #sep: ký tự đặc biệt dùng để ngăn cách các trường với nhau
    #remove: có hay không loại bỏ các cột được gộp với nhau, mặc định là có (TRUE),
      #nếu FALSE thì kết quả sẽ thể hiện cả các cột đã bị gộp

  #Giờ hãy cùng nhau gộp các cột thông tin về sinh viên lại với nhau:
  score %>%
    unite(col = StudentInfo, StudentID, Name, Gender, sep = "~", remove = FALSE)