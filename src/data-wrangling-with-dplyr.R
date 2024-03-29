
#install.packages("tidyverse")
library(tidyverse)

#+++++++++++++++++++++++++++++++++
# 1. Pipe operator
#+++++++++++++++++++++++++++++++++
## Ví dụ 1:
  x <- seq(2, 100, 2)
  
  # Tính độ lệch chuẩn
  sqrt(sum((x-mean(x))^2)/(length(x)-1))
  sd(x)
  
  # Sử dụng %>%:
  ((x - x %>% mean)^2 %>% sum / (x %>% length - 1)) %>% sqrt
  
  mean(x) 
  # Tương đương với:
  x %>% mean
  
  sqrt(sum(x)) * 100
  # Tương đương với:
  x %>% sum %>% sqrt * 100
  sqrt(x %>% sum) # trong ví dụ này, x %>% sum được hiểu là biến của hàm sqrt. 
  
  model1 <- mtcars %>% lm(mpg ~ cyl + disp + wt, data = .)
  model1 %>% summary

## Ví dụ 2:  
  mtcars %>%
    subset(hp > 100) %>%
    aggregate(. ~ cyl, data = ., FUN = . %>% mean %>% round(2)) %>%
    transform(kpl = mpg * 0.4251)
  # Tương đương với:
  new_func <- function(x){
    return(round(mean(x), 2))
  }
  mtcars %>%
    subset(hp > 100) %>%
    aggregate(. ~ cyl, data = ., FUN = new_func) %>%
    transform(kpl = mpg * 0.4251)

## Ví dụ 3:
  check_data <- function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  }
  check_data(5)
  check_data("5")
  x <- seq(2, 10, 1)
  check_data(x)
  y <- c("I", "am", "Duc")
  check_data(y)
  y <- as.factor(y)
  check_data(y)
  
  #Cấu trúc nhanh với %>%: bạn có thể truyền yếu tố LHS qua hàm mới bạn đang định nghĩa, như sau:
  5 %>% 
  (function(x){
    if(is.numeric(x)) print("variable is numeric")
    if(is.logical(x)) print("variable is logical")
    if(is.factor(x)) print("variable is factor")
    if(is.character(x)) print("variable is charactor")
  })

  x %>%
    (function(x){
      if(is.numeric(x)) print("variable is numeric")
      if(is.logical(x)) print("variable is logical")
      if(is.factor(x)) print("variable is factor")
      if(is.character(x)) print("variable is charactor")
    })

#+++++++++++++++++++++++++++++++++
# 2 dplyr Các hàm cơ bản
#+++++++++++++++++++++++++++++++++
##2.1 Lấy dữ liệu từ bảng mẫu:
  
  mtcars %>% head(5) # lấy 5 dòng đầu của dữ liệu
  mtcars %>% tail(5) # lấy 5 dòng cuối của dữ liệu
  
  # sample_n() hoặc hàm sample_frac() để lấy dữ liệu của các dòng ngẫu nhiên trong bảng dữ liệu. Va
  mtcars %>% sample_n(10) # lấy 10 dòng dữ liệu ngẫu nhiên trong bảng mtcars - tương đương với cấu trúc: "SELECT TOP 10 * FROM MTCARS" trong SQL.
  iris %>% sample_frac(.1) # lấy 10 % tổng số dòng có trong bảng iris

##2.2 Lọc dữ liệu theo điều kiện
  #Trong gói dplyr, hàm filter() và hàm slice() được sử dụng để làm công việc lọc dữ liệu 
  
  filter(mtcars, mpg >= 21, cyl == 6)
  #Hàm filter() rất tương đồng với hàm subset() trong base R (đã được xây dựng sẵn trong môi trường gốc của R mà không cần gọi bất kỳ gói nào khi sử dụng).
  #Với filter(), tên của dòng tự động bị loại bỏ, trong khi đó subset() vẫn lưu lại tên dòng của dữ liệu.
  
  subset(mtcars, mpg >= 21 & cyl == 6)
  #Tương đương với:
  mtcars %>%
    subset(mpg >= 21) %>%
    subset(cyl == 6)


  #1.Điều kiện VÀ: có thể sử dụng dấu “,”, hoặc “&” để ngăn cách các điều kiện với nhau:
    mtcars %>%
      filter(mpg >= 21 & cyl == 6)
    #Tương đương với:
    mtcars %>%
      filter(mpg >= 21, cyl == 6)
    
    #So sánh với subset(): subset chỉ cho phép dùng dầu “&” để ngăn các các điều kiện VÀ với nhau:
    mtcars %>%
      subset(mpg >= 21 & cyl == 6)
    
    #Giá trị nằm trong một khoảng [a, b] có thể được lấy ra bằng 2 cách 1) biến >= a & biến <= b; 2) between(biến, a, b). 
    #Trong cách 1) chúng ta sử dụng điều kiện VÀ, cách 2 chúng ta sử dụng hàm between của dplyr để thay cho >= và <=.
    
    mtcars %>%
      filter(mpg %>% between(19, 21))
    #Tương đương với:
    mtcars %>%
      filter(mpg >= 19 & mpg <= 21)

  #2.Điều kiện HOẶC: dùng dấu “|” để ngăn cách các điều kiện với nhau, tương tự với subset()
    mtcars %>%
      filter(mpg >= 21 | cyl == 6)
    
    mtcars %>%
      subset(mpg >= 21 | cyl == 6)
    
    #Khi điều kiện HOẶC là chuỗi các giá trị rời rạc áp dụng cho cùng một trường, 
    #chúng ta có thể làm ngắn gọn hơn với cấu trúc “%in%” thay vì cấu phải liệt kê tất cả các điều kiện đơn lẻ và ngăn cách nhau bởi dấu “|”:
    
    mtcars %>%
      filter(carb == 4 | carb == 3 | carb == 1)
    #Tương đương với:
    mtcars %>%
      filter(carb %in% c(1, 3, 4))
    
    #Với hàm subset():
    mtcars %>%
      subset(carb %in% c(1, 3, 4))
    
    #Hàm slice() cho phép người dùng lấy dữ liệu dựa vào vị trí của dòng dữ liệu. 
    #Khái niệm dòng của dữ liệu thường không được áp dụng với dữ liệu bảng biểu có quan hệ (relational database) 
    #do khái niệm về tên (vị trí) của dòng dữ liệu không được đề cập (áp dụng với loại dữ liệu bảng biểu này).
    #Trong R, dữ liệu được xác định rõ ràng thứ tự dòng, do đó slice() được sử dụng để xác định vị trí này.
    
    mtcars %>%
      slice(c(1, 3, 5, 7)) # liệt kê các dòng thứ 1, 3, 5, 7
    
    mtcars %>%
      slice(.$cyl == 4) # liệt kê các dòng có giá trị bằng 4
    
    mtcars %>%
      slice(row_number() == 1) # liệt kê giá trị dòng 1
    
    mtcars %>%
      slice(order(.$qsec) %>% head) # sắp xếp lại dữ liệu mtcars theo cột qsec sau đó lấy 6 dòng dữ liệu (có giá trị qsec cao nhất)
    
##2.3 Sắp xếp dữ liệu

  #Ngoài việc lọc dữ liệu có điều kiện, chúng ta cũng thường xuyên thực hiện việc sắp xếp dữ liệu theo một trật tự nhất định nào đó khi xem dữ liệu. 
  #Hàm arrange() hỗ trợ công việc này.
  mtcars %>%
    arrange(mpg, cyl, disp)
  
  #Trong ví dụ trên, dữ liệu mtcars sẽ được sắp xếp theo thứ tự từ thấp lên cao cho lần lượt các cột mpg, cyl và disp với thứ tự ưu tiên tương ứng. 
  #Hàm arrange() có điểm tương đồng với hàm order() trong R base, nhưng hàm order() chỉ áp dụng cho vector và áp dụng cho 1 vector tại một thời điểm.
  mtcars[order(mtcars$mpg, decreasing =  T),]
  
  #Hàm arrange() có thể được kết hợp với hàm desc() - hàm hỗ trợ để thể hiện dữ liệu theo chiều giảm dần (descending) 
  #để thực hiện được việc sắp xếp dữ liệu theo ý muốn của người dùng. Hàm desc() được dùng để bổ trợ cho hàm arrange().
  mtcars %>%
    arrange(vs, gear %>% desc, carb) %>% # sắp xếp theo cột vs từ thấp đến cao, sau đó cột gear từ cao xuống thấp và cuối cùng là carb từ thấp đến cao.
    head
  
  #Ví dụ khác của arrange():
  mtcars %>%
    filter(mpg %>% between(19, 21)) %>%
    arrange(vs, gear %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg từ 19 đến 21, sau đó dữ liệu được sắp xếp lần lượt theo cột vs (tăng dần) và cột gear (giảm dần)

##2.4 Lấy dữ liệu theo trường thông tin mong muốn
  #Khi bạn cần lấy chi tiết các trường thông tin nào trong bảng dữ liệu, bạn có thể dùng hàm select() để nhặt chi tiết các trường. 
  #Hàm select() tương đồng với tham số select trong hàm subset().
  mtcars %>%
    select(mpg, cyl, disp) %>%
    head
  
  #Đối với subset():
  mtcars %>%
    subset(select = c(mpg, cyl, disp)) %>%
    head
  
  #Ngoài việc lấy chi tiết các cột (liệt kê từng cột) khi lấy dữ liệu trên 1 bảng, bạn có thể dùng một số hàm sau để hỗ trợ việc lấy trường dữ liệu được nhanh hơn:
  #starts_with(“Ký tự là thông tin mong muốn”): các cột dữ liệu ccó tên hứa các ký tự mong muốn đứng ở đầu của tên, ví dụ:
  iris %>%
    select(starts_with("Petal")) %>%
    head
  
  #ends_with(“Ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa các ký tự mong muốn ở cuối của tên, ví dụ:
  iris %>%
    select(ends_with("Length")) %>%
    head
  
  #contains(“Ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa chính xác các ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:
  iris %>%
    select(contains("etal")) %>%
    head
  
  #matches(“Dạng ký tự là thông tin mong muốn”): các cột dữ liệu có tên chứa các ký tự có dạng ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:
  iris %>%
    select(matches(".t.")) %>% # lấy tất cả các cột có tên chứa chữ t và có ký tự khác ở trước và sau (các ký tự chỉ chứa chữ t mà chữ t ở đâu hoặc cuối tên sẽ không được tính vào)
    head
  
  #Ví dụ khác của select():
  mtcars %>%
    filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
    select(disp, hp, drat, wt) %>%
    arrange(wt %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg <= 21  và cyl bằng 6 hoặc 8, sau đó chỉ lấy các trường disp, hp, drat và wt, dữ liệu cuối cùng được sắp xếp theo cân nặng (wt) từ cao xuống thấp


  #Bây giờ bạn muốn đặt tên mới cho các trường mà bạn lấy từ một bảng dữ liệu, bạn có thể làm như sau:
  mtcars %>%
    filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
    select(`miles per gallon` = mpg
           , cylinder = cyl
           , displacement = disp
           , `horse power` = hp
           , drat
           , weight = wt) %>%
    arrange(weight %>% desc)

  #Nếu bạn muốn lấy toàn bộ tất cả các trường trong bảng dữ liệu và chỉ muốn thay đổi tên của một số cột, 
  #bạn có thể dùng hàm rename() để thay thế cho select() với những bảng dữ liệu có nhiều cột.
  mtcars %>%
    filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
    rename(displacement = disp
           , `horse power` = hp
           , weight = wt) %>%
    arrange(weight %>% desc)

##2.5 Lọc các giá trị duy nhất
  #Đôi khi, bạn chỉ muốn nhặt ra các giá trị duy nhất trong bảng dữ liệu. Để làm được việc này bạn có thể dùng hàm distinct(),
  #hàm này tương đồng với hàm unique() trong R base.
  mtcars %>%
    distinct(cyl) # lấy các giá trị duy nhất của cột dữ liệu cyl trong bảng mtcars

  mtcars %>%
    distinct(vs, gear) # lấy các cặp dữ liệu duy nhất của 2 cột vs và gear trong bảng mtcars
  #Tương đương với:
  mtcars$cyl %>%
    unique
  
  mtcars[, c("vs", "gear")] %>%
    unique()
  #Sự khác biệt rõ ràng nhất giữa distinct() và unique() mà các bạn có thể quan sát ở trên là với hàm unique(), 
  #chúng ta bắt buộc phải liệt kê rõ ràng vector hoặc bảng dữ liệu nào cần lấy danh sách giá trị duy nhất.
  #Trong khi đó, với distinct() bạn có thể tìm danh sách các giá trị duy nhất của 1 cột, hoặc nhiều cột từ một bảng dữ liệu nào đó.
  
##2.6 Tạo mới trường dữ liệu
  #Trong quá trình xử lý dữ liệu, rất nhiều lúc bạn muốn tạo thêm các trường dữ liệu mới (trường dữ liệu phát sinh)
  #dựa vào công thức có liên quan đến các trường dữ liệu hiện tại (business rules). Hàm mutate() được sử dụng để làm công việc này.
  #Trong R base, chúng ta cũng có thể thực hiện được yêu cầu này với hàm transform(), tuy nhiên với năng lực có phần hạn chế hơn, 
  #chúng ta sẽ đi qua ví dụ để làm rõ ý này.
  mtcars %>%
    select(mpg) %>%
    mutate(kpg = mpg * 1.61) %>%
    head

  #Chúng ta vừa tạo ra cột dữ liệu mới có tên kpg (km per gallon) và được tính dựa vào trường mpg với công thức kpg=mpg∗1.61
  #Dữ liệu nhận về sẽ là 2 cột dữ liệu mpg và kmp tương ứng. Bạn có thể làm điều tương tự với transform():
  mtcars %>%
    subset(select = mpg) %>%
    transform(kpg = mpg * 1.61) %>%
    head

  #Chúng ta có thể xử lý tương tự cho nhiều trường dữ liệu cùng lúc:
  mtcars %>%
    select(mpg, wt) %>%
    mutate(kpg = mpg * 1.61
           , wt_kg = wt/2.2) %>%
    head
  
  mtcars %>%
    subset(select = c(mpg, wt)) %>%
    transform(kpg = mpg * 1.61
              , wt_kg = wt/2.2) %>%
    head

  #Sự khác biệt giữa mutate() và transform() ở chỗ với mutate() chúng ta có thể tạo ra trường mới dựa vào trường mới được tạo cùng lúc, 
  #trong khi đó transform() không cho phép thực hiện điều này - transform() chỉ thực hiện được việc tạo cột mới dựa vào các trường đã được thiết lập trước trên bảng dữ liệu.
  
  mtcars %>%
    select(mpg, qsec) %>%
    mutate(kpg = mpg * 1.61 # km per gallon
           , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
           , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
    ) %>%
    head

  #Với transfrom() bạn chỉ có thể làm được như sau:
  
  mtcars %>%
    select(mpg, qsec) %>%
    transform(kpg = mpg * 1.61 # km per gallon
              , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
    ) %>%
    transform(gqsec_km = 1/kpg * 1/4) %>% # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km) 
    head

  #Như vậy, với transform(), trường gqsec_km chỉ được tạo ra sau khi trường kpg đã được tạo ra.

  #Với những tình huống khi người dùng không muốn lấy các trường thông tin cũ mà chỉ muốn lấy các trường thông tin mới thì có
  #thể sử dụng hàm transmute() với cấu trúc giống như hàm mutate.
  mtcars %>%
    transmute(kpg = mpg * 1.61) %>%
    head
  
  mtcars %>%
    transmute(kpg = mpg * 1.61 # km per gallon
              , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
              , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
    ) %>%
    head

##2.7 Tổng hợp các chỉ tiêu dữ liệu
  #Trong quá trình xử lý dữ liệu, rất nhiều khi bạn phải tổng hợp dữ liệu theo các cách như: tính tổng, tính số dư bình quân, phương sai, 
  #tổng số lượng quan sát… Trong gói dplyr, bạn có thể sử dụng hàm summarise() để thực hiện công việc này.
  iris %>%
    summarise(mean_SL = Sepal.Length %>% mean
              , total_SL = Sepal.Length %>% sum
              , sd_SL = Sepal.Length %>% sd
    )

  #Phía trên chỉ là ví dụ đơn giản mà chúng ta có thể thay thế bằng hàm summary() trên R base, tuy nhiên, kết hợp giữa hàm summarise() 
  #và hàm group_by() trên dplyr sẽ cho chúng ta có cái nhìn về dữ liệu tổng hợp một cách đa chiều hơn. Hàm group_by() cho phép dữ liệu 
  #tổng hợp được gộp lại theo một hoặc nhiều trường thông tin khác nhau, giúp người phân tích có thể nhìn dữ liệu theo từ chiều riêng biệt 
  #hoặc gộp các chiều thông tin với nhau.

  iris %>%
    group_by(Species) %>% # gộp theo chiều Species
    summarise(total_SL = Sepal.Length %>% sum # tính tổng giá trị
              , mean_SL = Sepal.Length %>% mean # tính số trung bình
              , count = n() # đếm số lượng quan sát 
              , standard_deviation = Sepal.Length %>% sd # tính độ lệch chuẩn
    )

  #Kết quả của chúng ta nhận được giờ đã ý nghĩa hơn rất nhiều khi các con số này được nhìn theo chiều về thực thể (Species), 
  #qua đó giúp chúng ta có đánh giá, so sánh giữa các thực thể với nhau.
  
  data("UCBAdmissions") # dữ liệu về hồ sơ ứng tuyển của sinh viên trường UC Berkeley
  str(UCBAdmissions) # kiểm tra cấu trúc dữ liệu của bảng

  admissions <- as.data.frame(UCBAdmissions) # quy đổi bảng dữ liệu về dạng data.frame (dữ liệu dạng bảng biểu)
  admissions %>%
    group_by(Admit, Gender) %>%
    summarise(total_frq = Freq %>% sum
              , mean_frq = Freq %>% mean
              , sd_frq = Freq %>% sd
    )

  #Kết qủa trên cho chúng ta cái nhìn chi tiết hơn về tổng số lượng sinh viên ứng tuyển, số lượng sinh viên ứng tuyển bình
  #quân và độ lệch chuẩn của số lượng sinh viên được chia theo giới tính và kết quả xét tuyển của trường (nhận, không nhận).

##2.8 Ví dụ tổng hợp
  #Vừa rồi chúng ta đã đi qua những hàm cơ bản trong dplyr được sử dụng thường xuyên trong quá trình xử lý dữ liệu.
  #Giờ chúng ta sẽ cùng đi qua một ví dụ tổng hợp hơn để cùng nhau áp dụng các kiến thức đã học được.
  #Chúng ta sẽ sử dụng dữ liệu về các khoản vay của khách hàng để làm ví dụ tổng hợp cho phần này.

  # Tải dữ liệu lên môi trường R
  loan <- read.csv(".../FactLoan.csv")
  names(loan) <- tolower(names(loan)) # đổi tên cột về dạng chữ thường
  head(loan)

  #Một số thông tin cơ bản về dữ liệu dư nợ:
  #cust_no: mã khách hàng
  #currency: loại tiền vay
  #branch_id: mã chi nhánh của khách hàng
  #pro_name: tên sản phẩm khách hàng sử dụng (ví dụ: mortgage: là sản phẩm về mua nhà, đất với các khoản vay của KH được sử dụng cho mục đích này)
  #due_days: số ngày khách hàng nợ chưa trả được gốc và lãi của khoản vay
  #balance: tổng số dư nợ của khách hàng tại thời điểm tính toán

  #Với dữ liệu về dư nợ của khách hàng, các bạn có một số công việc cần làm sau:
  #Nhặt ra 10 dòng dữ liệu ngẫu nhiên của dữ liệu
  #Lọc ra các giá trị duy nhất của chi nhánh (branch_id) và số lượng sản phẩm (pro_name)
  #Tạo thêm trường thông tin liên quan đến nhóm nợ, trong đó 
    #Nhóm 1: nợ < 30 ngày;
    #Nhóm 2: >= 30, < 60 ngày;
    #Nhóm 3: >= 60, < 120 ngày;
    #Nhóm 4: > 120, <= 360 ngày;
    #Nhóm 5 > 360 ngày
  #Lọc ra thông tin về khoản vay có gía trị > 5 triệu
  #Tổng hợp dữ liệu theo nhóm nợ, theo tên sản phẩm về: số lượng khách hàng, tổng dư nợ và số lượng ngày quá hạn bình quân 
  #cho tất cả các khách hàng và cho các khách hàng có khoảng vay lớn hơn 30 triệu.

#+++++++++++++++++++++++++++++++++
# 3 Các hàm nâng cao trong dplyr
#+++++++++++++++++++++++++++++++++

##3.1 Hàm điều kiện phân nhóm
  #Chắc hẳn trong quá trình phân tích và xử lý dữ liệu, chúng ta sẽ tạo thêm các trường mới hoặc tính toán dữ liệu dựa vào
  #từng điều kiện khác nhau để đưa ra giá trị của trường hoặc cách tính cho dữ liệu. Ví dụ: nhóm tuổi của khách hàng (KH) được
  #tính dựa vào độ tuổi trong các khoảng như: <= 18 tuổi sẽ là “nhóm 1”, từ 18-25 là “nhóm 2”, từ 25-35 là “nhóm 3”… hay xếp loại 
  #sinh viên dựa vào điểm số như < 5 là “kém”, từ 5-7 là “khá”, từ 7-9 là “giỏi”, từ 9-10 là “xuất sắc”. Hoặc trong kinh doanh,
  #bạn muốn tính thưởng cho KH thì sẽ phải dùng nhiều công thức khác nhau như KH thuộc VIP sẽ nhân 1 tỷ lệ, KH medium 1 tỷ lệ khác, 
  #hay KH thông thường thì sẽ 1 tỷ lệ khác…. Chúng ta sẽ cùng đi qua một vài ví dụ để nắm được hàm xử dụng trong dpyr.

  #Trong dplyr, hàm case_when() được tạo ra cho những công việc như ở trên.
  a <- data.frame(number = 1:20) # tạo một bảng dữ liệu có số thứ tự từ 1 đến 20
  a$nhom1 <- case_when(
    a$number <= 5 ~ "nhom 1", # nhóm 1: số từ 1 đến 5
    a$number > 5 & a$number <= 10 ~ "nhom 2", # nhóm 2: số từ 6 đến 10
    a$number > 10 & a$number <= 15 ~ "nhom 3", # nhóm 3: số từ 11 đến 15
    TRUE ~ "nhom 4" # các số còn lại
  )

  #Lưu ý: với case_when, chúng ta không thể áp dụng pipe operator cho một bảng dữ liệu như các hàm khác và áp dụng với một trường dữ liệu trong bảng. chỉ cho vector.

  #Ví dụ trên chúng ta cũng có thể làm trong R base theo cách sau:
  a$nhom2[a$number <= 5] <- "nhom 1"
  a$nhom2[a$number > 5 & a$number <= 10] <- "nhom 2"
  a$nhom2[a$number > 10 & a$number <= 15] <- "nhom 3"
  a$nhom2[a$number > 15] <- "nhom 4"
  a

  #Chúng ta có thể kết hợp case_when() và mutate() (hoặc transmute()) để lấy dữ liệu được như mong muốn. 
  #Tuy nhiên, chúng ta vẫn cần lưu ý là sẽ cần dùng dấu chấm (“.”) để truyền biến vào trong hàm case_when(). 
  #Ví dụ sau sẽ làm rõ ý của câu trên.
  a %>%
    mutate(number
           , group = case_when(.$number <= 5 ~ "nhom 1" # number không được hiểu là cột dữ liệu của x, trừ khi chúng ta dùng "." làm đại diện cho x để được truyền vào hàm case_when() thông qua pipe operator.
                               , .$number > 5 & .$number <= 10 ~ "nhom 2"
                               , .$number > 10 & .$number <= 15 ~ "nhom 3"
                               , TRUE ~ "nhom 4")
    )

##3.2 Hàm gộp các hai bảng dữ liệu
  #Trong R base, chúng ta thường dùng hàm merge() để gộp 2 bảng dữ liệu với nhau dựa vào 1 hoặc nhiều trường dữ liệu giống nhau. 
  #Trong gói dplyr, chúng ta có các hàm riêng biệt được sử dụng cho mục đích này, tuy thuộc vào kết quả đầu ra mà chúng ta mong muốn. 
  #Chúng ta sẽ đi qua 4 hàm cơ bản của dplyr và so sách với hàm merge() trong R base.
  
  #Giả sử chúng ta cần gộp 2 bảng dữ liệu x và y, các hàm để gộp 2 bảng dữ liệu sẽ như sau:
  #Hàm inner_join(x, y…): được xử dụng để lấy tất cả dữ liệu chỉ có trên bảng x và y, ví dụ:
  x <- data.frame(`StudentID` = seq(1, 10, 1), maths = c(10, 8, 7, 6, 7.8, 4, 7.7, 9, 9.5, 6.5))
  y <- data.frame(`StudentID` = seq(2, 20, 2), physics = c(8, 9.5, 7.5, 6, 5.5, 6.5, 7.8, 8.2, 8, 7.5))
  x %>%
    inner_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, lấy các dòng dữ liệu mà 2 bảng cùng có.
  #Tương đương với hàm merge():
  x %>%
    merge(y, by = "StudentID", all = F) # tham số all = F/FALSE (hoặc T/TRUE): có lấy toàn bộ dữ liệu của 2 bảng hay không, F/FALSE sẽ chỉ lấy dữ liệu có trên cả 2 bảng.

  #Hàm full_join(x, y…): lấy dữ liệu có cả trên bảng x, y, ví dụ:
  x %>%
   full_join(y, by = "StudentID") # gộp 2 bảng dữ liệu a và b, dùng trường StudentID để map 2 bảng với nhau, lấy tất cả dữ liệu của 2 bảng

  #Các giá trị về điểm toán (maths) sẽ trả về NA cho các StudentID không tồn tại trên bảng y và ngược lại cho bảng x với các
  #giá trị điểm vật lý (physics) của các StudentID không tồn tại trên bảng x.
  #Tương đương với hàm merge():
  x %>%
    merge(y, by = "StudentID", all = T) # ngược lại với ví dụ trên về merge(), tham số all chuyển về T/TRUE để lấy dữ liệu trên cả 2 bảng

  #Hàm left_join(x, y…): lấy dữ liệu chỉ có trên bảng x, ví dụ:
  x %>%
    left_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng x

  #Với các StudentID không có giá trị trên bảng y, cột physics sẽ trả về giá trị NA
  #Tương đương với merge():
  x %>%
    merge(y, by = "StudentID", all.x = T) # tham số all.x = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng x

  #Hàm right_join(x, y…): lấy dữ liệu chỉ có trên bảng y, ví dụ:
  x %>%
    right_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng y

  #Với các StudentID không có giá trị trên bảng x, cột maths sẽ trả về giá trị NA
  #Tương đương với merge():
  x %>%
    merge(y, by = "StudentID", all.y = T) # tham số all.y = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng y

  #Trong trường hợp cột dữ liệu dùng để map có tên khác nhau, cấu trúc câu lệnh có thể khác đi một chút:
  names(x)[1] <- "StudentID1"
  names(y)[1] <- "StudentID2"
  x %>%
    inner_join(y, by = c("StudentID1" = "StudentID2")) # tương tự cho các hàm khác trong dplyr

  #Lưu ý: khi tên cột cần map giữa 2 bảng khác nhau thì kết quả đầu ra sẽ chỉ thể hiện tên của bảng x. Các trường còn lại sẽ được giữ nguyên tên
  #Tương đương với merge():
  x %>%
    merge(y, by.x = "StudentID1", by.y = "StudentID2") 

  #lưu ý: với merge(), khi chúng ta không bổ sung tham số về kết quả đầu ra sẽ lấy trên 1 trong 2 bảng hoặc cả 2 bảng (all; all.x; all.y), 
  #hàm sẽ mặc định chỉ lấy dữ liệu có trên cả 2 bảng - tương đương với all = F/FAlSE

  #Nếu 2 bảng dữ liệu cần nhiều hơn một cột dữ liệu để map được dữ liệu giữa 2 bảng với nhau, chúng ta có thể làm như sau:
  x$UniversityID1 <- c(paste('00', seq(1, 9, 1), sep = ""), '010')
  y$UniversityID2 <- c(paste('00', seq(2, 8, 2), sep = ""), '011', paste('0', seq(30, 50, 5), sep = ""))
  
  x %>%
    inner_join(y, by = c("StudentID1" = "StudentID2", "UniversityID1" = "UniversityID2"))

  #Nếu các cột dữ liệu chung có tên giống nhau, cấu trúc câu lệnh sẽ đơn giản hơn rất nhiều:
  names(x)[1] = "StID"
  names(y)[1] = "StID"
  names(x)[3] = "UniID"
  names(y)[3] = "UniID"
  x %>%
    inner_join(y, by = c("StID", "UniID"))
  #Tương tự như với hàm merge():
  names(x)[1] = "StID1"
  names(y)[1] = "StID2"
  names(x)[3] = "UniID1"
  names(y)[3] = "UniID2"
  x %>%
    merge(y, by.x = c("StID1", "UniID1"), by.y = c("StID2", "UniID2"))
  
  names(x)[1] = "StID"
  names(y)[1] = "StID"
  names(x)[3] = "UniID"
  names(y)[3] = "UniID"
  x %>%
    merge(y, by = c("StID", "UniID"))

#+++++++++++++++++++++++++++++++++
# 4 Ví dụ tổng hợp
#+++++++++++++++++++++++++++++++++
  #Trong ví dụ này, chúng ta sẽ bổ sung thêm thông tin về chi nhánh (branch), và thông tin về khách hàng (customer) 
  #để biết thêm các chiều thông tin khác nhau của các khoản vay của khách hàng.
  
  # Tải các loại dữ liệu cho bài giảng:
  branch <- read.csv(".../DimBranch.csv")
  customer <- read.csv(".../DimCustomer.csv")
  head(branch)
  head(customer)
  names(customer) <- tolower(names(customer)) # chuyển đổi chữ hoa sang chữ thường
  names(branch) <- tolower(names(branch))

  #Một số thông tin cơ bản về dữ liệu:
  #Branch: thông tin về chi nhánh
  #BRANCH_ID: mã chi nhánh
  #AREA: thông tin về vùng của chi nhánh, được chia là 13 vùng
  #REGION: thông tin về miền của chi nhánh (3 miền)
  #Customer: thông tin về khách hàng
  #CUST_NO: mã số khách hàng
  #GENDER: giới tính của khách hàng
  #BOD: thông tin về ngày sinh của khách hàng
  #PROVINCE: thông tin về nơi cư chú (tỉnh thành) của khách hàng

  #Với dữ liệu chúng ta có về dư nợ, về chi nhánh và thông tin về khách hàng, một số công việc mà chúng ta cần làm như sau:
  #Tạo bảng dữ liệu có thông tin về khách hàng về giới tính, độ tuổi, nhóm tuổi, số dư nợ và nhóm nợ.(gợi ý: dựa vào thông tin trên 2 bảng loan và customer)
  #Tổng hợp số liệu về tổng dư nợ, dư nợ trung bình, tổng số khách hàng theo giới tính, nhóm tuổi và nhóm nợ
  #Vẽ đồ thì tổng hợp kết quả trên
  #Tổng hợp dữ liệu về khách hàng về miền, giới tính, nhóm tuổi bao gồm tổng dư nợ, số dư trung bình và số lượng khách hàng
  #Vẽ đồ thị tổng hợp kết quả trên
  
  #Chúng ta sẽ cùng nhau đi qua ví dụ 1, 2, 3. Các ví dụ 4 và 5, các bạn sẽ dành thời gian riêng của mình để tự nghiên cứu.
  library(lubridate) # sử dụng gói lubridate để chuyển đổi dữ liệu dưới dạng date
  customer$bod <- ymd(customer$bod)

  # Câu 1: xử lý dữ liệu
  loan_new <- loan %>%
    inner_join(customer, by = c("cust_no")) %>%
    mutate(age = Sys.Date() %>% difftime(bod, units = "days") %>% as.numeric %>% divide_by(365) %>% round(0)
           , ovd_group = case_when(.$due_days < 30 ~ "nhom 1"
                                   , .$due_days >= 30 & .$due_days < 60 ~ "nhom 2"
                                   , .$due_days >= 60 & .$due_days < 120 ~ "nhom 3"
                                   , .$due_days >= 120 & .$due_days < 360 ~ "nhom 4"
                                   , TRUE ~ "nhom 5"
                                   
           )
    ) %>%
    mutate(age_group = case_when(.$age <= 18 ~ "nhom 1"
                                 , .$age > 18 & .$age <= 30 ~ "nhom 2"
                                 , .$age > 30 & .$age <= 45 ~ "nhom 3"
                                 , .$age > 45 & .$age <= 65 ~ "nhom 4"
                                 , TRUE ~ "nhom 5"
    )
    ) %>%
    select(cust_no, gender, age, age_group, ovd_group, balance)
  loan_new
  
  # Câu 2: tổng hợp dữ liệu
  loan_sum <- loan_new %>%
    group_by(gender, age_group, ovd_group) %>%
    summarise(no_cust = n() # đến số lượng khách hàng
              , tot_bal = balance %>% sum
              , mean_bal = balance %>% mean
    )
  loan_sum

  # Câu 3: vẽ đồ thị dữ liệu tổng hợp
  library(ggplot2)
  head(loan_sum)
    
  loan_sum %>%
    ggplot(aes(no_cust, tot_bal)) +
    geom_point(aes(col = gender), size = 2) +
    labs(x = "So luong khach hang", y = "Tong du no") 