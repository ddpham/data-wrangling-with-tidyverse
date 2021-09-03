# 1.Giới thiệu

`tidyverse` là tổ hợp các thư viện (package/library) được sử dụng trên R với những tính năng chuyên cho việc xử lý, tổng hợp dữ liệu, trực quan hóa dữ liệu (visualization). Bài viết này chúng ta sẽ cùng đi qua các phương pháp xử lý, tổng hợp dữ liệu cở bản và nâng cao sử dụng các thư viên như: dppyr, tidyr và reshap2. Ngoài ra, các bạn cũng sẽ được giới thiệu về pipeoperator là phương pháp sâu chuỗi các thao tác xử lý dữ liệu với nhau thành dây chuyền thay vì phải chia nhỏ ra thành nhiều bước hoặc sử dụng nhiều đóng mở ngoặc (nested). Việc sử dụng pipeoperator cũng giúp cho việc đọc code được dễ dàng hơn.

Chúng ta cần tải thư viện về trước khi sử dụng, ở đây, cho pipeoperator, chúng ta sẽ dùng pipeR thay vì sử dụng pipeoperator của dplyr (magrittr). Pipeoperator của pipeR thật sự ưu việt hơn rất nhiều so với phần còn lại trong R.

```r
#install.packages(c("tidyverse", "pipeR"))
library(tidyverse)
library(pipeR)
```

# 2. Nội dung chính
Chúng ta sẽ chia nội dung thành 3 phần chính:

1. Giới thiệu về pipe operator vs pipeR
2. Các phương pháp biến đổi dữ liệu với dyplyr
3. Các phương pháp biến đổi dữ liệu với tidyer và reshape2

## Giới thiệu về pipe operator

Pipe operator (%>%) là khái niệm về việc viết code theo cách đơn giản và dễ theo dõi giúp cho người đọc và người viết code trên R có thể theo dõi được code một cách dễ dàng nhất. Trên R, thông thường người dùng sẽ viết code dưới dạng trong ngoặc (nested), và cấu trúc câu lệnh sẽ phức tạp khi có nhiều thao tác tính toán, biến đổi (hàm) được xử dụng để trả về kết quả cuối cùng. Khái niệm pipe operator được khởi xướng từ gói magrittr với nhiều tính năng hữu dụng, hỗ trợ người viết code có thể viết code trên R được hiệu quả và dễ theo dõi hoặc sửa trong quá trình chạy và update code.  Gói dplyr có ứng dụng một số tính năng cơ bản của pipe operator, cụ thể là cấu trúc %>% với một số tính năng cơ bản của pipe operator từ gói magrittr. 

Ví dụ đơn giản của %>%:
```r
x <- seq(2, 100, 2)

# Tính độ lệch chuẩn
sqrt(sum((x-mean(x))^2)/(length(x)-1))
sd(x)
```
Câu lệnh ở trên rất phức tạp, cần nhiều đóng, mở ngoặc để gộp các hàm lại với nhau. Với pipe operator, câu lệnh của chúng ta sẽ đơn giản hơn như sau:

```r
((x - x %>% mean)^2 %>% sum / (x %>% length - 1)) %>% sqrt
```

Trong ví dụ trên, chúng ta cần phải dùng tổng cộng  6 cặp (), tuy nhiên, khi dùng pipe operator, số lượng cặp () giảm đi còn 3 (1/2!). Logic của pipe operator khá khác biệt so với logic của (). Đối với (), chúng ta sẽ đọc thông tin từ trong cặp () bên trong ra cặp () bên ngoài, trong khi đó, logic của pipe operator là code được đọc từ trái sang phải. Pipe operator vẫn tuân theo các quy luật tính toán cơ bản trong toán học như các ccông thức trong ngoặc () sẽ được xử lý trước và quy tắc xử lý các thuật toán, công thức toán học sẽ trái sang phải...

*Diễn giải cho ví dụ trên*: x trừ trung bình của x; tất cả sau đó bình phương; sau đó được tính tổng lại; rồi chia cho 1 số, số này là tổng số của các giá trị nằm trong x trừ đi 1; kết quả của phép chia trên được căn bậc 2 để lấy kết quả cuối cùng

Một số đặc tính cơ bản của %>%:

  1. Theo mặc định, Phía tay trái (LHS) sẽ được chuyển tiếp thành yếu tố đầu tiên của hàm được sử dụng phía tay phải (RHS), ví dụ:
```r
mean(x) 
# Tương đương với:
x %>% mean

sqrt(sum(x)) * 100
# Tương đương với:
x %>% sum %>% sqrt * 100
```

  2. %>% có thể được sử dụng trong dạng (), tuy nhiên, được xuất hiện trong một cú pháp là biến của một hàm, ví dụ:
```r
sqrt(x %>% sum) # trong ví dụ này, x %>% sum được hiểu là biến của hàm sqrt. 
```
  
  3. Khi LHS không còn là yếu tố đầu tiên của một hàm RHS, thì dấu "." được sử dụng để định vị cho LHS, ví dụ:
```r
model1 <- mtcars %>% lm(mpg ~ cyl + disp + wt, data = .)
model1 %>% summary
```  
 
  Trong tình huống trên, tham số về dữ liệu trong hàm lm không phải là ở đầu, mà sau phần công thức, nên  chúng ta sẽ dùng dấu "." như là đại diện của thực thể mtcars ở bên ngoài (LHS) của hàm lm.
  
  4. Khi hàm RHS chỉ yêu cầu có một yếu tố, thì () có thể được lược bỏ để code  được tối giản (ví dụ như ở ví dụ mục 3)
  
  5. Dấu "." trong pipe operator đôi khi cũng được đặt LHS của pipe operator có thể được sử dụng như là một hàm và hàm này là kết quả của chuỗi hàm RHS, ví dụ:
```r
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
```

Một khái niệm quan trọng của của %>% có thể được sử dụng thường xuyên trong dplyr là *lambda*. Khái niệm này được sử dụng khi chúng ta truyền yếu tố phía tay trái (LHS) vào một hàm mới chưa được định nghĩa sẵn mà có thể tối giản cấu chúc của hàm này. Ví dụ:

Chúng ta muốn tạo ra một hàm để check loại dữ liệu của một biến, chúng ta sẽ làm theo 2 bước tuần tự sau: 1) tao hạm, 2) áp dụng hàm cho biến 

Bước 1: tạo hàm
```r
check_data <- function(x){
  if(is.numeric(x)) print("variable is numeric")
  if(is.logical(x)) print("variable is logical")
  if(is.factor(x)) print("variable is factor")
  if(is.character(x)) print("variable is charactor")
}
```

Bước 2: Áp dụng hàm cho biến
```r
check_data(5)
check_data("5")
x <- seq(2, 10, 1)
check_data(x)
y <- c("I", "am", "Duc")
check_data(y)
y <- as.factor(y)
check_data(y)
```

Cấu trúc nhanh với %>%: bạn có thể truyền yếu tố LHS qua hàm mới bạn đang định nghĩa, như sau:
```r
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
```

Tất nhiên, *lamda* trong gói dplyr chỉ thực sự hữu dụng khi chúng ta dùng hàm này một lần và không muốn mất công tạo một hàm mới, nếu hàm được sử dụng nhiều lần thì cách tốt nhất là định nghĩa hàm, sau đó dùng %>% để truyền biến vào hàm. 

## Các hàm cơ bản trong dplyr

### Lấy dữ liệu mẫu từ bảng dữ liệu
Khi tiếp cận với một bảng dữ liệu, phần lớn người phân tích và xử lý dữ liệu thường làm thao tác đầu tiên là quan sát các giá trị mẫu của dữ liệu. Trong R Base, chắc hẳn các bạn đều dùng hàm head() và tail() để nhặt ra một số dòng đầu tiên  và cuối cùng của dữ liệu.
```r
mtcars %>% head(5) # lấy 5 dòng đầu của dữ liệu
mtcars %>% tail(5) # lấy 5 dòng cuối của dữ liệu
```

Tuy nhiên các hàm head() và tail() đều đưa ra các gía trị của các dòng dữ liệu đầu tiên và cuối cùng của bảng dữ liệu. Khác với các hàm này một chút, trong gói dplyr, bạn có thể dùng hàm sample_n() hoặc hàm sample_frac() để lấy dữ liệu của các dòng ngẫu nhiên trong bảng dữ liệu. Với hàm sample_n() cho ta số lượng dòng theo yêu cầu, còn sample_frac() cho ta số lượng dòng bằng tỷ trọng của tổng số lượng dòng của toàn bộ bảng dữ liệu. Hàm sample_n() giống với cấu trúc lấy dữ liệu mẫu ngẫu nhiên trong SQL.
```r
mtcars %>% sample_n(10) # lấy 10 dòng dữ liệu ngẫu nhiên trong bảng mtcars - tương đương với cấu trúc: "SELECT TOP 10 * FROM MTCARS" trong SQL.
iris %>% sample_frac(.1) # lấy 10 % tổng số dòng có trong bảng iris
```

Ngoài việc nhìn nhanh các thông tin trên bảng dữ liệu mà bạn muốn phân tích, hai hàm trên cũng hỗ trợ bạn trong việc lấy dữ liệu mẫu của một bảng dữ liệu để phân tích hoặc xây dựng mô hình. 


### Lọc dữ liệu theo điều kiện

Thường xuyên trong quá trình xử lý và phân tích dữ liệu, người dùng sẽ phải lọc dữ liệu theo điều kiện nào đó, ví dụ lấy danh sách khách hàng nam có độ tuổi từ 35 trở lên, lấy các hợp đồng có giá trị từ 10 triệu trở lên hay đại loại vậy. Trong gói dplyr, hàm filter() và hàm slice() được sử dụng để làm công việc này.
```r
filter(mtcars, mpg >= 21, cyl == 6)
```

Hàm filter() rất tương đồng với hàm subset() trong base R (đã được xây dựng sẵn trong môi trường gốc của R mà không cần gọi bất kỳ gói nào khi sử dụng). Với filter(), tên của dòng tự động bị loại bỏ, trong khi đó subset() vẫn lưu lại tên dòng của dữ liệu.
```r
subset(mtcars, mpg >= 21 & cyl == 6)
```

Tương đương với:
```r
mtcars %>%
  subset(mpg >= 21) %>%
  subset(cyl == 6)
```

  1.Điều kiện **VÀ**: có thể sử dụng dấu ",", hoặc "&" để ngăn cách các điều kiện với nhau:
```r
mtcars %>%
  filter(mpg >= 21 & cyl == 6)
```

Tương đương với:
```r
mtcars %>%
  filter(mpg >= 21, cyl == 6)
```

So sánh với subset(): subset chỉ cho phép dùng dầu "&" để ngăn các các điều kiện **VÀ** với nhau:
```r
mtcars %>%
  subset(mpg >= 21 & cyl == 6)
```

Giá trị nằm trong một khoảng **[a, b]** có thể được lấy ra bằng 2 cách 1) biến **>=** a & biến **<=** b; 2) between(biến, a, b). Trong cách 1) chúng ta sử dụng điều kiện **VÀ**, cách 2 chúng ta sử dụng hàm between của dplyr để thay cho **>=** và **<=**.
```r
mtcars %>%
  filter(mpg %>% between(19, 21))
```  

Tương đương với:
```r
mtcars %>%
  filter(mpg >= 19 & mpg <= 21)
```
  
  2.Điều kiện **HOẶC**: dùng dấu "|" để ngăn cách các điều kiện với nhau, tương tự với subset()
```r
mtcars %>%
  filter(mpg >= 21 | cyl == 6)
mtcars %>%
  subset(mpg >= 21 | cyl == 6)
```
  
  Khi điều kiện **HOẶC** là chuỗi các giá trị rời rạc áp dụng cho cùng một trường, chúng ta có thể làm ngắn gọn hơn với cấu trúc "%in%" thay vì cấu phải liệt kê tất cả các điều kiện đơn lẻ và ngăn cách nhau bởi dấu "|":
```r
mtcars %>%
 filter(carb == 4 | carb == 3 | carb == 1)
```

  Tương đương với:
```r
mtcars %>%
  filter(carb %in% c(1, 3, 4))
```

Với hàm subset():
```r
mtcars %>%
  subset(carb %in% c(1, 3, 4))
```

Hàm slice() cho phép người dùng lấy dữ liệu dựa vào vị trí của dòng dữ liệu. Khái niệm dòng của dữ liệu thường không được áp dụng với dữ liệu bảng biểu có quan hệ (relational database) do khái niệm về tên (vị trí) của dòng dữ liệu không được đề cập (áp dụng với loại dữ liệu bảng biểu này). Trong R, dữ liệu được xác định rõ ràng thứ tự dòng, do đó slice() được sử dụng để xác định vị trí này.
```r
mtcars %>%
  slice(c(1, 3, 5, 7)) # liệt kê các dòng thứ 1, 3, 5, 7
mtcars %>%
  slice(.$cyl == 4) # liệt kê các dòng có giá trị bằng 4
mtcars %>%
  slice(row_number() == 1) # liệt kê giá trị dòng 1
mtcars %>%
  slice(order(.$qsec) %>% head) # sắp xếp lại dữ liệu mtcars theo cột qsec sau đó lấy 6 dòng dữ liệu (có giá trị qsec cao nhất)
```


### Sắp xếp dữ liệu

Ngoài việc lọc dữ liệu có điều kiện, chúng ta cũng thường xuyên thực hiện việc sắp xếp dữ liệu theo một trật tự nhất định nào đó khi xem dữ liệu. Hàm arrange() hỗ trợ công việc này. 
```r
mtcars %>%
  arrange(mpg, cyl, disp)
```

Trong ví dụ trên, dữ liệu mtcars sẽ được sắp xếp theo thứ tự từ thấp lên cao cho lần lượt các cột mpg, cyl và disp với thứ tự ưu tiên tương ứng. Hàm arrange() có điểm tương đồng với hàm order() trong R base, nhưng hàm order() chỉ áp dụng cho vector và áp dụng cho 1 vector tại một thời điểm.
```r
mtcars[order(mtcars$mpg, decreasing =  T),]
```

Hàm arrange() có thể được kết hợp với hàm desc() - hàm hỗ trợ để thể hiện dữ liệu theo chiều giảm dần (descending) để thực hiện được việc sắp xếp dữ liệu theo ý muốn của người dùng. Hàm desc() được dùng để bổ trợ cho hàm arrange().
```r
mtcars %>%
  arrange(vs, gear %>% desc, carb) %>% # sắp xếp theo cột vs từ thấp đến cao, sau đó cột gear từ cao xuống thấp và cuối cùng là carb từ thấp đến cao.
  head
```


Ví dụ khác của arrange():
```r
mtcars %>%
  filter(mpg %>% between(19, 21)) %>%
  arrange(vs, gear %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg từ 19 đến 21, sau đó dữ liệu được sắp xếp lần lượt theo cột vs (tăng dần) và cột gear (giảm dần)
```


### Lấy dữ liệu theo trường thông tin mong muốn

Khi bạn cần lấy chi tiết các trường thông tin nào trong bảng dữ liệu, bạn có thể dùng hàm select() để nhặt chi tiết các trường. Hàm select() tương đồng với tham số select trong hàm subset().
```r
mtcars %>%
  select(mpg, cyl, disp) %>%
  head
```

Đối với subset():
```r
mtcars %>%
  subset(select = c(mpg, cyl, disp)) %>%
  head
```

Ngoài việc lấy chi tiết các cột (liệt kê từng cột) khi lấy dữ liệu trên 1 bảng, bạn có thể dùng một số hàm sau để hỗ trợ việc lấy trường dữ liệu được nhanh hơn:

  - starts_with("Ký tự là thông tin mong muốn"): các cột dữ liệu ccó tên hứa các ký tự mong muốn đứng ở đầu của tên, ví dụ:
```r
iris %>%
  select(starts_with("Petal")) %>%
  head
```

  - ends_with("Ký tự là thông tin mong muốn"): các cột dữ liệu có tên chứa các ký tự mong muốn ở cuối của tên, ví dụ:
```r
iris %>%
  select(ends_with("Length")) %>%
  head
```

  - contains("Ký tự là thông tin mong muốn"): các cột dữ liệu có tên chứa chính xác các ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:
```r
iris %>%
  select(contains("etal")) %>%
  head
```

 - matches("Dạng ký tự là thông tin mong muốn"): các cột dữ liệu có tên chứa các ký tự có dạng ký tự mong muốn ở bất kỳ vị trí nào của tên, ví dụ:
```r
iris %>%
  select(matches(".t.")) %>% # lấy tất cả các cột có tên chứa chữ t và có ký tự khác ở trước và sau (các ký tự chỉ chứa chữ t mà chữ t ở đâu hoặc cuối tên sẽ không được tính vào)
  head
```

Ví dụ khác của select():
```r
mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  select(disp, hp, drat, wt) %>%
  arrange(wt %>% desc) # lấy dữ liệu từ mtcars thỏa mãn: mpg <= 21  và cyl bằng 6 hoặc 8, sau đó chỉ lấy các trường disp, hp, drat và wt, dữ liệu cuối cùng được sắp xếp theo cân nặng (wt) từ cao xuống thấp
```

Bây giờ bạn muốn đặt tên mới cho các trường mà bạn lấy từ một bảng dữ liệu, bạn có thể làm như sau:
```r
mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  select(`miles per gallon` = mpg
         , cylinder = cyl
         , displacement = disp
         , `horse power` = hp
         , drat
         , weight = wt) %>%
  arrange(weight %>% desc)
```

Nếu bạn muốn lấy toàn bộ tất cả các trường trong bảng dữ liệu và chỉ muốn thay đổi tên của một số cột, bạn có thể dùng hàm rename() để thay thế cho select() với những bảng dữ liệu có nhiều cột.
```r
mtcars %>%
  filter(mpg <= 21 & cyl %in% c(6, 8)) %>%
  rename(displacement = disp
         , `horse power` = hp
         , weight = wt) %>%
  arrange(weight %>% desc)
```


### Lọc các giá trị duy nhất

Đôi khi, bạn chỉ muốn nhặt ra các giá trị duy nhất trong bảng dữ liệu. Để làm được việc này bạn có thể dùng hàm distinct(), hàm này tương đồng với hàm unique() trong R base.
```r
mtcars %>%
  distinct(cyl) # lấy các giá trị duy nhất của cột dữ liệu cyl trong bảng mtcars
mtcars %>%
  distinct(vs, gear) # lấy các cặp dữ liệu duy nhất của 2 cột vs và gear trong bảng mtcars
```

Tương đương với:
```r
mtcars$cyl %>%
  unique
mtcars[, c("vs", "gear")] %>%
  unique()
```

Sự khác biệt rõ ràng nhất giữa distinct() và unique() mà các bạn có thể quan sát ở trên là với hàm unique(), chúng ta bắt buộc phải liệt kê rõ ràng vector hoặc bảng dữ liệu nào cần lấy danh sách giá trị duy nhất. Trong khi đó, với distinct() bạn có thể tìm danh sách các giá trị duy nhất của 1 cột, hoặc nhiều cột từ một bảng dữ liệu nào đó.


### Tạo mới trường dữ liệu

Trong quá trình xử lý dữ liệu, rất nhiều lúc bạn muốn tạo thêm các trường dữ liệu mới (trường dữ liệu phát sinh) dựa vào công thức có liên quan đến các trường dữ liệu hiện tại (business rules). Hàm mutate() được sử dụng để làm công việc này. Trong R base, chúng ta cũng có thể thực hiện được yêu cầu này với hàm transform(), tuy nhiên với năng lực có phần hạn chế hơn, chúng ta sẽ đi qua ví dụ để làm rõ ý này.
```r
mtcars %>%
  select(mpg) %>%
  mutate(kpg = mpg * 1.61) %>%
  head
```

Chúng ta vừa tạo ra cột dữ liệu mới có tên kpg (km per gallon) và được tính dựa vào trường mpg với công thức $kpg = mpg * 1.61$. Dữ liệu nhận về sẽ là 2 cột dữ liệu mpg và kmp tương ứng. Bạn có thể làm điều tương tự với transform():
```r
mtcars %>%
  subset(select = mpg) %>%
  transform(kpg = mpg * 1.61) %>%
  head
```

Chúng ta có thể xử lý tương tự cho nhiều trường dữ liệu cùng lúc:
```r
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
```

Sự khác biệt giữa mutate() và transform() ở chỗ với mutate() chúng ta có thể tạo ra trường mới dựa vào trường mới được tạo cùng lúc, trong khi đó transform() không cho phép thực hiện điều này - transform() chỉ thực hiện được việc tạo cột mới dựa vào các trường đã được thiết lập trước trên bảng dữ liệu.

```r
mtcars %>%
  select(mpg, qsec) %>%
  mutate(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
         ) %>%
  head
```

Với transfrom() bạn chỉ có thể làm được như sau:
```r
mtcars %>%
  select(mpg, qsec) %>%
  transform(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         ) %>%
  transform(gqsec_km = 1/kpg * 1/4) %>% # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km) 
  head
```

Như vậy, với transform(), trường gqsec_km chỉ được tạo ra sau khi trường kpg đã được tạo ra.

Với những tình huống khi người dùng không muốn lấy các trường thông tin cũ mà chỉ muốn lấy các trường thông tin mới thì có thể sử dụng hàm transmute() với cấu trúc giống như hàm mutate.
```r
mtcars %>%
  transmute(kpg = mpg * 1.61) %>%
  head
mtcars %>%
  transmute(kpg = mpg * 1.61 # km per gallon
         , qsec_km = qsec * 1.61 # 1/4 km time từ 1/4 mile time (thời gian đi hết 1/4 km từ thời gian đi hết 1/4 dặm)
         , gqsec_km = 1/kpg * 1/4 # số lượng gallon tiêu tốn trong thời gian chạy được 1/4 km
         ) %>%
  head
```

### Tổng hợp các chỉ tiêu dữ liệu

Trong quá trình xử lý dữ liệu, rất nhiều khi bạn phải tổng hợp dữ liệu theo các cách như: tính tổng, tính số dư bình quân, phương sai, tổng số lượng quan sát... Trong gói dplyr, bạn có thể sử dụng hàm summarise() để thực hiện công việc này.
```r
iris %>%
  summarise(mean_SL = Sepal.Length %>% mean
            , total_SL = Sepal.Length %>% sum
            , sd_SL = Sepal.Length %>% sd
            )
```

Phía trên chỉ là ví dụ đơn giản mà chúng ta có thể thay thế bằng hàm summary() trên R base, tuy nhiên, kết hợp giữa hàm summarise() và hàm group_by() trên dplyr sẽ cho chúng ta có cái nhìn về dữ liệu tổng hợp một cách đa chiều hơn. Hàm group_by() cho phép dữ liệu tổng hợp được gộp lại theo một hoặc nhiều trường thông tin khác nhau, giúp người phân tích có thể nhìn dữ liệu theo từ chiều riêng biệt hoặc gộp các chiều thông tin với nhau.
```r
iris %>%
  group_by(Species) %>% # gộp theo chiều Species
  summarise(total_SL = Sepal.Length %>% sum # tính tổng giá trị
            , mean_SL = Sepal.Length %>% mean # tính số trung bình
            , count = n() # đếm số lượng quan sát 
            , standard_deviation = Sepal.Length %>% sd # tính độ lệch chuẩn
            )
```

Kết quả của chúng ta nhận được giờ đã ý nghĩa hơn rất nhiều khi các con số này được nhìn theo chiều về thực thể (Species), qua đó giúp chúng ta có đánh giá, so sánh giữa các thực thể với nhau. 
```r
data("UCBAdmissions") # dữ liệu về hồ sơ ứng tuyển của sinh viên trường UC Berkeley
str(UCBAdmissions) # kiểm tra cấu trúc dữ liệu của bảng
admissions <- as.data.frame(UCBAdmissions) # quy đổi bảng dữ liệu về dạng data.frame (dữ liệu dạng bảng biểu)
admissions %>%
  group_by(Admit, Gender) %>%
  summarise(total_frq = Freq %>% sum
            , mean_frq = Freq %>% mean
            , sd_frq = Freq %>% sd
  )
```

Kết qủa trên cho chúng ta cái nhìn chi tiết hơn về tổng số lượng sinh viên ứng tuyển, số lượng sinh viên ứng tuyển bình quân và độ lệch chuẩn của số lượng sinh viên được chia theo giới tính và kết quả xét tuyển của trường (nhận, không nhận).


### Ví dụ tổng hợp

Vừa rồi chúng ta đã đi qua những hàm cơ bản trong dplyr được sử dụng thường xuyên trong quá trình xử lý dữ liệu. Giờ chúng ta sẽ cùng đi qua một ví dụ tổng hợp hơn để cùng nhau áp dụng các kiến thức đã học được.
Chúng ta sẽ sử dụng dữ liệu về các khoản vay của khách hàng để làm ví dụ tổng hợp cho phần này. 
```r
# Tải dữ liệu lên môi trường R
loan <- read.csv("C:/Users/ddpham/Downloads/FactLoan.csv")
names(loan) <- tolower(names(loan)) # đổi tên cột về dạng chữ thường
head(loan)
```

Một số thông tin cơ bản về dữ liệu dư nợ:

  - cust_no: mã khách hàng
  
  - currency: loại tiền vay
  
  - branch_id: mã chi nhánh của khách hàng
  
  - pro_name: tên sản phẩm khách hàng sử dụng (ví dụ: mortgage: là sản phẩm về mua nhà, đất với các khoản vay của KH được sử dụng cho mục đích này)
  
  - due_days: số ngày khách hàng nợ chưa trả được gốc và lãi của khoản vay
  
  - balance: tổng số dư nợ của khách hàng tại thời điểm tính toán
  
Với dữ liệu về dư nợ của khách hàng, các bạn có một số công việc cần làm sau:

  1. Nhặt ra 10 dòng dữ liệu ngẫu nhiên của dữ liệu
  2. Lọc ra các giá trị duy nhất của chi nhánh (branch_id) và số lượng sản phẩm (pro_name)
  3. Tạo thêm trường thông tin liên quan đến nhóm nợ, trong đó Nhóm 1: nợ < 30 ngày; Nhóm 2: >= 30, < 60 ngày;  Nhóm 3:  >= 60, < 120 ngày; Nhóm 4: > 120, <= 360 ngày, Nhóm 5 > 360 ngày
  4. Lọc ra thông tin về khoản vay có gía trị > 5 triệu
  5. Tổng hợp dữ liệu theo nhóm nợ, theo tên sản phẩm về: số lượng khách hàng, tổng dư nợ và số lượng ngày quá hạn bình quân cho tất cả các khách hàng và cho các khách hàng có khoảng vay lớn hơn 30 triệu.
  
## Các hàm nâng cao trong dplyr

### Hàm điều kiện phân nhóm

Chắc hẳn trong quá trình phân tích và xử lý dữ liệu, chúng ta sẽ tạo thêm các trường mới hoặc tính toán dữ liệu dựa vào từng điều kiện khác nhau để đưa ra giá trị của trường hoặc cách tính cho dữ liệu. Ví dụ: nhóm tuổi của khách hàng (KH) được tính dựa vào độ tuổi trong các khoảng như: <= 18 tuổi sẽ là "nhóm 1", từ 18-25 là "nhóm 2", từ 25-35 là "nhóm 3"... hay xếp loại sinh viên dựa vào điểm số như < 5 là "kém", từ 5-7 là "khá", từ 7-9 là "giỏi", từ 9-10 là "xuất sắc". Hoặc trong kinh doanh, bạn muốn tính thưởng cho KH thì sẽ phải dùng nhiều công thức khác nhau như KH thuộc VIP sẽ nhân 1 tỷ lệ, KH medium 1 tỷ lệ khác, hay KH thông thường thì sẽ 1 tỷ lệ khác.... Chúng ta sẽ cùng đi qua một vài ví dụ để nắm được hàm xử dụng trong dpyr.

Trong dplyr, hàm case_when() được tạo ra cho những công việc như ở trên. 
```r
a <- data.frame(number = 1:20) # tạo một bảng dữ liệu có số thứ tự từ 1 đến 20
a$nhom1 <- case_when(
  a$number <= 5 ~ "nhom 1", # nhóm 1: số từ 1 đến 5
  a$number > 5 & a$number <= 10 ~ "nhom 2", # nhóm 2: số từ 6 đến 10
  a$number > 10 & a$number <= 15 ~ "nhom 3", # nhóm 3: số từ 11 đến 15
  TRUE ~ "nhom 4" # các số còn lại
)
```

*Lưu ý*: với case_when, chúng ta không thể áp dụng pipe operator cho một bảng dữ liệu như các hàm khác và áp dụng với một trường dữ liệu trong bảng.
chỉ cho vector. 

Ví dụ trên chúng ta cũng có thể làm trong R base theo cách sau:
```r
a$nhom2[a$number <= 5] <- "nhom 1"
a$nhom2[a$number > 5 & a$number <= 10] <- "nhom 2"
a$nhom2[a$number > 10 & a$number <= 15] <- "nhom 3"
a$nhom2[a$number > 15] <- "nhom 4"
a
```

Chúng ta có thể kết hợp case_when() và mutate() (hoặc transmute()) để lấy dữ liệu được như mong muốn. Tuy nhiên, chúng ta vẫn cần lưu ý là sẽ cần dùng dấu chấm (".") để truyền biến vào trong hàm case_when(). Ví dụ sau sẽ làm rõ ý của câu trên.
```r
a %>%
  mutate(number
         , group = case_when(.$number <= 5 ~ "nhom 1" # number không được hiểu là cột dữ liệu của x, trừ khi chúng ta dùng "." làm đại diện cho x để được truyền vào hàm case_when() thông qua pipe operator.
                     , .$number > 5 & .$number <= 10 ~ "nhom 2"
                     , .$number > 10 & .$number <= 15 ~ "nhom 3"
                     , TRUE ~ "nhom 4")
         )
```

### Hàm gộp các hai bảng dữ liệu

Trong R base, chúng ta thường dùng hàm merge() để gộp 2 bảng dữ liệu với nhau dựa vào 1 hoặc nhiều  trường dữ liệu giống nhau. Trong gói dplyr, chúng ta có các hàm riêng biệt được sử dụng cho mục đích này, tuy thuộc vào kết quả đầu ra mà chúng ta mong muốn. Chúng ta sẽ đi qua 4 hàm cơ bản của dplyr và so sách với hàm merge() trong R base. 

Giả sử chúng ta cần gộp 2 bảng dữ liệu x và y, các hàm để gộp 2 bảng dữ liệu sẽ như sau:

  - Hàm inner_join(x, y...): được xử dụng để lấy tất cả dữ liệu chỉ có trên bảng x và y, ví dụ:
```r
x <- data.frame(`StudentID` = seq(1, 10, 1), maths = c(10, 8, 7, 6, 7.8, 4, 7.7, 9, 9.5, 6.5))
y <- data.frame(`StudentID` = seq(2, 20, 2), physics = c(8, 9.5, 7.5, 6, 5.5, 6.5, 7.8, 8.2, 8, 7.5))
x %>%
  inner_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, lấy các dòng dữ liệu mà 2 bảng cùng có.
```

Tương đương với hàm merge():
```r
x %>%
  merge(y, by = "StudentID", all = F) # tham số all = F/FALSE (hoặc T/TRUE): có lấy toàn bộ dữ liệu của 2 bảng hay không, F/FALSE sẽ chỉ lấy dữ liệu có trên cả 2 bảng.
```

  - Hàm full_join(x, y...): lấy dữ liệu có cả trên bảng x, y, ví dụ:
```r
x %>%
  full_join(y, by = "StudentID") # gộp 2 bảng dữ liệu a và b, dùng trường StudentID để map 2 bảng với nhau, lấy tất cả dữ liệu của 2 bảng
```

Các giá trị về điểm toán (maths) sẽ trả về NA cho các StudentID không tồn tại trên bảng y và ngược lại cho bảng x với các giá trị điểm vật lý (physics) của các StudentID không tồn tại trên bảng x.

Tương đương với hàm merge():
```r
x %>%
  merge(y, by = "StudentID", all = T) # ngược lại với ví dụ trên về merge(), tham số all chuyển về T/TRUE để lấy dữ liệu trên cả 2 bảng
```

  - Hàm left_join(x, y...): lấy dữ liệu chỉ có trên bảng x, ví dụ:
```r
x %>%
  left_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng x
```

Với các StudentID không có giá trị trên bảng y, cột physics sẽ trả về giá trị NA

Tương đương với merge():
```r
x %>%
  merge(y, by = "StudentID", all.x = T) # tham số all.x = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng x
```

  - Hàm right_join(x, y...): lấy dữ liệu chỉ có trên bảng y, ví dụ:
```r
x %>%
  right_join(y, by = "StudentID") # gộp 2 bảng dữ liệu x và y, dùng trường StudentID để map 2 bảng với nhau, chỉ lấy dữ liệu có trên bảng y
```

Với các StudentID không có giá trị trên bảng x, cột maths sẽ trả về giá trị NA

Tương đương với merge():
```r
x %>%
  merge(y, by = "StudentID", all.y = T) # tham số all.y = T/TRUE: tương đương với việc chỉ lấy toàn bộ dữ liệu trên bảng y
```


Trong trường hợp cột dữ liệu dùng để map có tên khác nhau, cấu trúc câu lệnh có thể khác đi một chút:
```r
names(x)[1] <- "StudentID1"
names(y)[1] <- "StudentID2"
x %>%
  inner_join(y, by = c("StudentID1" = "StudentID2")) # tương tự cho các hàm khác trong dplyr
```

*Lưu ý*: khi tên cột cần map giữa 2 bảng khác nhau thì kết quả đầu ra sẽ chỉ thể hiện tên của bảng x. Các trường còn lại sẽ được giữ nguyên tên

Tương đương với merge():
```r
x %>%
  merge(y, by.x = "StudentID1", by.y = "StudentID2") 
```

*lưu ý*: với merge(), khi chúng ta không bổ sung tham số về kết quả đầu ra sẽ lấy trên 1 trong 2 bảng hoặc cả 2 bảng (all; all.x; all.y), hàm sẽ mặc định chỉ lấy dữ liệu có trên cả 2 bảng - tương đương với all = F/FAlSE

Nếu 2 bảng dữ liệu cần nhiều hơn một cột dữ liệu để map được dữ liệu giữa 2 bảng với nhau, chúng ta có thể làm như sau:
```r
x$UniversityID1 <- c(paste('00', seq(1, 9, 1), sep = ""), '010')
y$UniversityID2 <- c(paste('00', seq(2, 8, 2), sep = ""), '011', paste('0', seq(30, 50, 5), sep = ""))

x %>%
  inner_join(y, by = c("StudentID1" = "StudentID2", "UniversityID1" = "UniversityID2"))
```

Nếu các cột dữ liệu chung có tên giống nhau, cấu trúc câu lệnh sẽ đơn giản hơn rất nhiều:
```r
names(x)[1] = "StID"
names(y)[1] = "StID"
names(x)[3] = "UniID"
names(y)[3] = "UniID"
x %>%
  inner_join(y, by = c("StID", "UniID"))
```

Tương tự như với hàm merge():
```r
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
```


## Ví dụ tổng hợp

Trong ví dụ này, chúng ta sẽ bổ sung thêm thông tin về chi nhánh (branch), và thông tin về khách hàng (customer) để biết thêm các chiều thông tin khác nhau của các khoản vay của khách hàng.
```r
# Tải các loại dữ liệu cho bài giảng:
branch <- read.csv("C:/Users/ddpham/Downloads/DimBranch.csv")
customer <- read.csv("C:/Users/ddpham/Downloads/DimCustomer.csv")
head(branch)
head(customer)
names(customer) <- tolower(names(customer)) # chuyển đổi chữ hoa sang chữ thường
names(branch) <- tolower(names(branch))
```

Một số thông tin cơ bản về dữ liệu:

  - Branch: thông tin về chi nhánh
    
    + BRANCH_ID: mã chi nhánh
    
    + AREA: thông tin về vùng của chi nhánh, được chia là 13 vùng
    
    + REGION: thông tin về miền của chi nhánh (3 miền)
    
  - Customer: thông tin về khách hàng
  
    + CUST_NO: mã số khách hàng
    
    + GENDER: giới tính của khách hàng
    
    + BOD: thông tin về ngày sinh của khách hàng
    
    + PROVINCE: thông tin về nơi cư chú (tỉnh thành) của khách hàng

Với dữ liệu chúng ta có về dư nợ, về chi nhánh và thông tin về khách hàng, một số công việc mà chúng ta cần làm như sau:

  1. Tạo bảng dữ liệu có thông tin về khách hàng về giới tính, độ tuổi, nhóm tuổi, số dư nợ và nhóm nợ.(gợi ý: dựa vào thông tin trên 2 bảng loan và customer)
  2. Tổng hợp số liệu về tổng dư nợ, dư nợ trung bình, tổng số khách hàng theo giới tính, nhóm tuổi và nhóm nợ
  3. Vẽ đồ thì tổng hợp kết quả trên
  4. Tổng hợp dữ liệu về khách hàng về miền, giới tính, nhóm tuổi bao gồm tổng dư nợ, số dư trung bình và số lượng khách hàng
  5. Vẽ đồ thị tổng hợp kết quả trên
  

Chúng ta sẽ cùng nhau đi qua ví dụ 1, 2, 3. Các ví dụ 4 và 5, các bạn sẽ dành thời gian riêng của mình để tự nghiên cứu.
```r
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

# Câu 2: tổng hợp dữ liệu
loan_sum <- loan_new %>%
  group_by(gender, age_group, ovd_group) %>%
  summarise(no_cust = n() # đến số lượng khách hàng
            , tot_bal = balance %>% sum
            , mean_bal = balance %>% mean
  )
  
# Câu 3: vẽ đồ thị dữ liệu tổng hợp
library(ggplot2)
head(loan_sum)
loan_sum %>%
  ggplot(aes(no_cust, tot_bal)) +
  geom_point(aes(col = gender), size = 2) +
  labs(x = "So luong khach hang", y = "Tong du no") 
```
  
## Xoay chiều dữ liệu vs tidyer và reshape2

### Gộp dữ liệu theo trục (unpivot table)

Khái niệm gộp dữ liệu theo trục là việc gộp và tổng hợp dữ liệu của nhiều cột dữ liệu vào thành một cột chung chứa giá trị của các cột này hoặc giá trị tổng hợp từ các cột này. Một trong những lợi ích lớn nhất của việc gộp dữ liệu theo trục là hỗ trợ người phân tích dữ liệu trong việc vẽ đồ thị. Nếu bạn đã sử dụng gói ggplot2 để vẽ đồ thì, bạn sẽ thấy việc gộp dữ liệu là điều bạn cần làm trước khi vẽ bất kỳ đồ thị nào. Trong gói tidyr, chúng ta có hàm gather(), còn trong gói reshape2 chúng ta có hàm melt(). Tính năng và ứng dụng của 2 hàm này phụ thuộc vào mục đích sử dụng của người dùng.

Giả sử chúng ta có dữ liệu về điểm số của sinh viên như sau:
```r
# Tạo dữ liệu sample:
StudentID <- c("1004", "1897", "1234", "1123", "1345", "1542", "1236", "7894", "6548", "7894")
Name <- c("Nam", "Hai", "Long", "Nguyet", "Nhat", "Nhung", "Huyen", "Duc", "Vu", "Giang")
Gender <- c("M", "F", "M", "F", "F", "F", "F","M", "M", "M")
English <- c(9, 8, 5, 7.5, 6, 6.5, 8.3, 4.5, 10, 5)
Maths <- c(10, 9, 8.9, 7, 6, 9.7, 7.8, 8.7, 7, 7.5)
History <- c(8, 7, 6, 5, 8.9, 6.5, 8.5, 7.2, 8.9, 9)
Status <- c("P", "P", "F", "F", "P", "P","P", "F", "P", "F")
score <- data.frame(StudentID, Name, Gender, English, Maths, History, Status)
```
Bây giờ chúng ta chỉ muốn tổng hợp dữ liệu về điểm số của sinh viên thành một cột dữ liệu theo từng sinh viên, và có một cột dữ liệu về tên môn học để nhận biết điểm của môn nào, chúng ta có thể dùng hàm gather() của gói tidyr. Hàm gather() có cấu trúc: gather(data, key, value, ...), trong đó:

- data: bảng dữ liệu cần gộp
- key: cột dữ liệu mới được tạo ra để lưu tên các cột được gộp
- value: cột dữ liệu mới được tạo ra để lưu giá trị của các cột được gộp tương ứng
- ...: chi tiết tên các cột được gộp.

Với cấu trúc trên, hày cùng nhau gộp dữ liệu score:
```r
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
```

Như vậy thông tin về điểm thi đã được gộp với nhau để tiện cho việc quan sát cũng như vẽ đồ thị.

Tương tự như hàm gather(), hàm melt() trong gói reshape2 cũng làm công việc tương tự. Hàm melt() có cấu trúc: melt(data, id.vars, measure.vars, variable.name = "variable", value.name, ...), trong đó:

- data: bảng dữ liệu cần gộp
- id.vars: là vector của các cột dữ liệu được giữ nguyên
- measure.vars: là vector của các cột được gộp
- variable.name: là tên của cột được sử dụng để lưu tên các cột được gộp
- value.name: laf tên của cột lưa giá trị của các cột được gộp
```r
score_melt <- score %>%
  melt(id.vars = c("StudentID", "Name", "Gender", "Status") # các cột này được giữ nguyên
       , measure.vars = c("English", "Maths", "History") # các cột được gộp với nhau
       , variable.name = "Subject"
       , value.name = "Score"
      )
score_melt
```

Có thể thấy score_melt và score_gather không khác nhau về cấu trúc và giá trị các ô dữ liệu. Hai hàm gather() và melt() đều trả về giá trị giống nhau nhưng cấu trúc có phần khác biệt nhau. Bạn có thể thấy hàm melt() có cấu trúc chi tiết hơn so với hàm gather(). Tuy nhiên, với cách thức của hàm melt() cho ta sự lựa chọn trong việc nhặt chi tiết các trường dữ liệu được giữ nguyên (chiều thông tin). Chỉ các trường thông tin được chọn này sẽ được lưu lại trên bảng dữ liệu mới.

Ví dụ khác: sử dụng dữ liệu iris, gộp các trường thông tin về chiều dài và chiều rộng của đài hoa và cánh hoa, đặt tên các thông tin này là Indicator còn cột lưu số liệu là Value:
```r
head(iris)
iris %>%
  gather("Indicator", "Value", -Species) %>%
  head
iris %>%
  melt(id.vars = "Species", measure.vars = c("Sepal.Length", "Petal.Length", "Sepal.Width", "Petal.Width"), variable.name = "Indicator", value.name = "Value") %>%
  head
```

Trong R base chúng ta có thể dùng hàm stack() để thực hiện công việc trên. Tuy nhiên, nếu chỉ thực hiện với hàm stack, chung ta sẽ nhận được kết quả không được như mong muốn do stack() chỉ hỗ trợ gộp các cột dữ liệu lại với nhau:
```r
score %>%
  stack(select = c("English", "History", "Maths"))
```

Đây chắc chắn không phải là kết quả mà bạn mong muốn. Để được kết quả tương tự như hàm melt() hoặc gather() đã làm, chúng ta sẽ kết hợp với hàm cbind() với stack() để thực hiện công việc trên:
```r
score %>%
  stack(select = c("English", "History", "Maths")) %>%
  cbind(score[, c("StudentID", "Name", "Gender", "Status")])
```


### Xoay dữ liệu theo trục (pivot table)

Khái niệm xoay dữ liệu theo trục có thể rất quen thuộc với nhiều bạn đọc, đặc biết với những ai đã và đang sử dụng Excel với pivot table. Xoay dữ liệu theo trục cho phép người dùng có thể nhìn dữ liệu theo nhiều sâu với cách thức tổng hợp dữ liệu khác nhau như: số lượng, tổng giá trị, giá trị bình quân, giá trị lớn nhất, nhỏ nhất... Trong R, với cả gói tidyr và reshape2, chúng ta có thể làm công việc tương tự với các hàm spread() và dcast() tương ứng.

Hàm spread() trong tidyr có cấu trúc như sau: spread(data, key, value, fill = NA, ...), trong đó:

- data: bảng dữ liệu thực hiện xoay chiều
- key: cột dữ liệu được sử dụng để phân rã ra nhiều cột
- value: tên của cột được sử dụng để điền các giá trị tương ứng cho các cột phân rã
- fill: nếu không có giá trị thì sẽ được thay thế bẳng giá trị tương ứng, mặc định là NA nếu không được nêu rõ.

Ví dụ:
```r
score_gather %>%
  spread(Subject, Score)
```

Với hàm spread(), chúng ta chỉ có thể duỗi dữ liệu ra từ dạng cột sang dạng hàng khi một cột dữ liệu chứa thông tin theo chiều các môn học được duỗi ra thành nhiều cột khác nhau, từng cột mới tương ứng với từng môn học và điểm của các môn học. Nếu chúng ta muốn nhìn dữ liệu với các chỉ số khác nhau như số dư trung bình, tổng số, số lượng vv... thì spread() sẽ không thể đáp ứng được những yêu cầu này. Tuy nhiên, với hàm dcast() từ gói reshape2, chúng ta có thể làm được công việc này.
Hàm dcast() có cấu trúc: dcast(data, formula, fun.aggregate = NULL, ...), trong đó:

- data: bảng dữ liệu cần xoay chiều
- formula: công thức thực hiện xoay chiều, có 2 về và được phân tách với nhau bởi dấu ~. Vế bên tay trái là các cột được giữ nguyên. Vế tay phải là các cột được xoay trục
- fun.aggregate: hàm đượ sử dụng để tổng hợp dữ liệu trong quá trình xoay trục như: tổng số, số lượng, số trung bình...

Với dữ liệu score_melt đã được xử lý vừa rồi, nếu chúng ta chỉ đơn thuần muốn duỗi dữ liệu ra thành nhiều cột mà không thực hiện việc tính toán, tổng hợp dữ liệu, thì tham số về hàm tổng hợp (fun.aggregate) sẽ không sử dụng:
```r
score_melt %>%
  dcast(formula = StudentID + Name + Gender + Status ~ Subject)
```

Nếu chúng ta muốn duỗi nhiều trường dữ liệu với nhau, ví dụ điểm môn + trượt/đỗ, chúng ta có thể làm bằng cách bổ sung trường vào vế tay phải của công thức (formula):
```r
score_melt %>%
  dcast(StudentID + Name + Gender ~ Subject + Status, fill = "")
```

Số lượng cột được sinh mới (xoay trục) sẽ là tích của số lượng các giá trị duy nhất của từng cột được xoay trục. Ở đây là 6 (3 * 2) (có 3 môn, 2 trạng thái). Trong code phía trên, chúng ta có thể dùng thêm tham số fill (mặc định là NA) để điền giá trị vào cho những ô dữ liệu không có giá trị (ở đây chúng ta để các giá trị này là trống - "").

Giờ chúng ta muốn thực hiện việc xoay trục dữ liệu, đồng thời thực hiện các tính toán về dữ liệu như tính tổng, tổng số lượng hoặc số trunh bình, chúng ta có thể làm như sau:
```r
library(dplyr)
loan <- read.csv("C:/Users/ddpham/Downloads/FactLoan.csv", sep = ",", header = T)
names(loan) <- tolower(names(loan))
loan <- distinct(loan) # lấy các dòng dữ liệu duy nhất của bảng dữ liệu
```

- Tính tổng số dư chi tiết cho từng sản phẩm, theo từng chi nhánh:
```r
pro_sum <- loan %>%
  select(branch_id, pro_name, balance) %>% # nhặt các trường branch_id, pro_name và balance cho việc xoay trục dữ liệu   
  dcast(branch_id ~ pro_name, fun.aggregate = sum)
head(pro_sum)
```

Kiểm tra lại kết quả với sản phẩm Others cho chi nhánh VN10116:
```r
loan %>%
  filter(branch_id == "VN10116", pro_name == "Others") %>%
  select(balance) %>%
  sum
```

- Tính số lượng khách hàng chi tiết cho từng sản phẩm, theo từng chi nhánh:
```r
pro_count <- loan %>%
  select(cust_no, branch_id, pro_name) %>%
  dcast(branch_id ~ pro_name, length)
head(pro_count)
```

chúng ta có thể check kết quả ở trên với 1 ví dụ nhỏ cho sản phẩm Mortgage và với chi nhánh VN10114, có 4 khách hàng:
```r
loan %>%
  filter(branch_id == 'VN10114', pro_name == 'Mortgage')
```

- Tính số dư trung bình cho từng sản phẩm, theo từng chi nhánh:
```r
pro_mean <- loan %>%
  select(branch_id, pro_name, balance) %>%
  dcast(branch_id ~ pro_name, mean)
head(pro_mean)
```

- Chúng ta cũng có thể tính các giá trị khác như: độ lệch chuẩn(sd); phương sai (vars); giá trị lớn nhất-nhỏ nhất (max-min)...

*lưu ý*: hàm dcast mặc định fun.aggregate là hàm length() nếu trong tình huống mà tham số fun.aggregate không được bổ sung trong hàm.

### Bổ sung dữ liệu trống/giá trị trắng (NA)

Trong quá trình tổng hợp dữ liệu, nhiều trường hợp dữ liệu tổng hợp bị trống hoặc trắng do dữ liệu không có hoặc dữ liêu đầu vào bị thiếu. Như ví dụ ở trên khi chúng ta tính toán số dư trung bình của các sản phẩm cho vay theo chi nhánh sẽ có một số sản phẩm không bán được tại chi nhánh nào đó, khiến số liệu đưa ra bị NA. Tuy nhiên, chúng ta lại không muốn để NA và muốn thay thế bằng giá trị nào đó thích hợp với hoàn cảnh. Để làm được việc này, chúng ta sẽ dùng một trong 2 hàm replace_na() trong gói tidyr.

Giả sử chúng ta muốn thay thế giá trị NA bằng 0, chúng ta có thể làm như sau:
```r
loan %>%
  select(branch_id, pro_name, balance) %>%
  dcast(branch_id ~ pro_name, mean) %>%
  replace_na(list(Auto = 0, Others = "Khong gia tri")) %>%
  head
```

Với hàm replace_na(), chúng ta phải liệt kê các trường cần thay thế giá trị NA bằng một list(danh sách các cột cần thay thế). Các trường thông tin còn lại không nằm trong list() này sẽ không được thay thế.

### Tách và gộp các cột dữ liệu với nhau

Rất nhiều khi trong quá trình tổng hợp dữ liệu, chúng ta muốn tách một cột dữ liệu ra thành nhiều cột dữ liệu hoặc ngược lại muốn gộp nhiều trường dữ liệu lại với nhau thành một cột dữ liệu duy nhất. 
Để thực hiện việc tách một trường dữ liệu ra thành nhiều trường, chúng ta sẽ dùng hàm separate() trong gói tidyr hoặc hàm colsplit() trong gói reshape2. Có sự khác biệt nhất định giữa 2 hàm này, chúng ta sẽ đi chi tiết ở dưới.
Hàm separate() có cấu trúc: separate(data, col, into, sep = "[^[:alnum:]]+", ...), trong đó:

- data: bảng dữ liệu có cột cần tách
- col: tên cột dữ liệu cần tách
- into: vector tên các cột mới sẽ được tạo ra từ cột bị tách
- sep: ký tự đặc biệt dùng để tách cột 

*lưu ý*: ký tự đặc biệt dùng để tách là ký tự có trong cột cần tách, người dùng hiểu đây chính là ký tự ngăn cách các nhóm giá trị cần tách trong cột dữ liệu ban đầu. Từng nhóm ký tự này sẽ trở thành các cột dữ liệu mới sau khi được tách ra sử dụng hàm separate().

Ví dụ:
```r
score_new <- data.frame(StudentInfo = paste(StudentID, Name, Gender, sep = "#"), English, History, Maths)
score_new %>%
  separate(StudentInfo, into = c("StudentID", "Name", "Gender"), sep = "#")
```

Tình huống trên là tương đối đơn giản khi các trước thông tin được ngăn cách với nhau bằng một ký tự đặc biệt duy nhất. Trên thực tế, khi bạn tiếp xúc với nhiều loại dữ liệu sẽ không thể trách việc các trường dữ liệu được ngăn cách với nhau bằng nhiều ký tự khác nhau hoặc trường thông tin chưa nhiều hơn thôn tin mà bạn cần... Ví dụ sau là một trong những trường hợp đó.
```r
Phone <- paste("091", (rnorm(10, 1, 10)  * 123456) %>% round(0) %>% abs, sep = "")
score_new1 <- data.frame(StudentInfo = paste(StudentID, Name, sep = "-") %>% paste(paste(Gender, Phone, sep = ""), sep = "#")
                         , English
                         , History
                         , Maths)
head(score_new1)
```

Trong ví dụ này, dữ liệu về sinh viên có hơn 2 ký tự đặc biệt ngăn cách các cột dữ liệu và có thểm thông tin về số điện thoại của sinh viên nhưng lại không có ngăn cách giữa số đt và giới tính của sinh viên. Để tách được dữ liệu như mong muốn, chúng ta sẽ làm như sau:
```r
score_new1 %>%
  separate(StudentInfo, into = c("StudentID", "Name", "Gender"), sep = "[-#]") %>%
  separate(Gender, into = "Gender_New", sep = "[[:digit:]]+")
```

*Diễn giải*: Trong ví dụ này, chúng ta phải thực hiện việc tách trường dữ liệu thành 2 lần, trong đó, lần 1 chúng ta tách ra thành 3 cột: StudentID, Name, Gender, các cột này được ngăn cách với nhau bằng ký tự "-" hoặc "#". Các ký tự "[-#]" có nghĩa là "-" hoặc "#". Sau đó, chúng ta tiếp tục tách trường Gender ra để chỉ lấy ký tự chữ của cột này bằng cách loại bỏ toàn bộ ký tự số. Chuỗi ký tự "[[:digit:]]+" có nghĩa là chuối các ký tự dạng số (digit) và có số lượng ký tự không giới hạn và > 1. Chúng ta sẽ đi qua các ký tự này với bài viết về xử lý dữ liệu dạng chữ.

Trong gói reshape2 chúng ta cũng có thể dùng hàm colsplit() với cấu trúc: colsplit(string, pattern, names), trong đó:

- string: vector các ký tự cần tách
- pattern: ký tự ngăn cách
- names: vector tên của các cột mới

Các bạn có thể thấy sự khác biệt khá lớn giữa separate() và colsplit() ở đây  chính là dữ liêu đầu vào của hàm. Với separate() thì dữ liệu đầu vào là bảng dữ liệu, trong đó, colsplit() sẽ là vector ký tự, hay chính là cột dữ liệu cần tách. Như vậy colsplit() sẽ kếm linh động hơn so với separate(). Với colsplit(), chúng ta có thể tách score_new như sau:

colsplit(string = score_new$StudentInfo, pattern = "#", names = c("StudentID", "Name", "Gender")) %>% 
  cbind(score_new[, -1]) # gộp với các cột còn lại (khác cột StudentInfo) để lấy được dữ liệu đầy đủ


Hàm colsplit sẽ thích hợp với vector ký tự hơn do đặc tính dữ liệu đầu vào của hàm. Trong khí đó, separate() có thể linh động hơn và được dùng nhiều cho dữ liệu dạng bảng biểu.


Trong tình huống ngược lại, nhiều khi bạn sẽ muốn gộp các trường thông tin lại với nhau thành một cột dữ liệu chung. Để làm được việc này, chúng ta sẽ sử dụng hàm unite() trong gói tidyr. Hàm unite() có cấu trúc: unite(data, col, ..., sep = "_", remove = TRUE), trong đó:

- data: bảng dữ liệu cần gộp các trường lại với nhau
- col: tên trường dữ liệu mới sau khi gộp các trường lại với nhau
- ...: tên các cột dữ liệu cần gộp với nhau
- sep: ký tự đặc biệt dùng để ngăn cách các trường với nhau
- remove: có hay không loại bỏ các cột được gộp với nhau, mặc định là có (TRUE), nếu FALSE thì kết quả sẽ thể hiện cả các cột đã bị gộp

Giờ hãy cùng nhau gộp các cột thông tin về sinh viên lại với nhau:
```r
score %>%
  unite(col = StudentInfo, StudentID, Name, Gender, sep = "~", remove = FALSE)
```