# GraphQL API Server



## 在 local 啟動 server

* git clone

* 在目錄中執行 `bundle install`

* development, test database 需要設定 username/password 為 apiserver/secret，並且有權限 create db

* 建立 db 與啟動 server
    ```
    bin/rails db:create
    bin/rails db:migrate
    bin/rails server
    ```



## 執行測試

```
bundle exec rspec
```



## 資料庫欄位簡單說明


* courses: 課程
    * title: 課程名稱
    * instructor: 講師名稱
    * description: 課程說明

* chapters: 章節
    * title: 章節名稱
    * order: 順序 (GraphQL 參數不需要用到，順序會根據 array 的順序)
    * course_id: 關聯課程

* lectures: 單元
    * title: 單元名稱
    * description: 單元說明
    * content: 單元內容
    * order: 順序 (GraphQL 參數不需要用到，順序會根據 array 的順序)
    * chapter_id: 關聯章節



## query 範例

``` 
query {
  course(id: 1) {
    id
    title
    instructor
    description
    chapters {
      id
      title
      lectures {
        id
        title
        description
        content
      }
    }
  }
}
```



## mutation 範例

```
mutation {
  createCourse(
    input: {
      title: "Course 1"
      instructor: "Instructor 1"
      description: "this is description"
      chapters: [
        {
          title: "Chapter 1"
          lectures: [
            {
              title: "Lecture 1",
              description: "this is lecture description"
              content:"this is text content for lecture 1"
            }
            {
              title: "Lecture 2"
              description: ""
              content:"this is text content for lecture 2"
            }
          ]
        }
        {
          title: "Chapter 2"
        }
      ]
    }
  ) {
    course {
      id
      title
      instructor
      description
      chapters {
        id
        title
        lectures {
          id
          title
          description
          content
        }
      }
    }
    errors
  }
}
```



## 專案架構


* 這是一個簡易的 GraphQL API Server，使用 graphql 這個 gem 來實作
    
    * https://graphql-ruby.org/


* 按照 GraphQL Ruby 預設，相關程式碼主要放在 `app/graphql` 目錄下


* `app/graphql` 中分為這幾個部份：
    
    * `types` - GraphQL 會使用到的各種資料型態，包括：object、query entry、mutation entry 等等
        * `types` 中另有個 `input` 資料夾用來放置 mutations 相關的 arguments，參考這篇的做法 https://www.digitalocean.com/community/tutorials/how-to-set-up-a-ruby-on-rails-graphql-api
    * `queries` - 放置 query，當中會定義需要的參數以及對應的 resolver
    * `mutations` - 放置 mutation，當中會定義需要的參數以及對應的 resolver



## 使用到的第三方 gem


* `graphql` - 實作 graphql 相關協定和基本架構


* `graphiql-rails` - 提供簡易的 graphiql Web UI，方便手動測試 GraphQL API


* `rspec-rails` - 使用 spec 的方式撰寫測試

* `factory_bot_rails` - 在測試中快速建立各種 object，讓測試可以著重於實際要測試的程式碼邏輯



## 程式碼中的註解


* 當有些實作方法不太直觀或可讀性較差時，為了讓其他協同的人或是未來的自己可以看懂，簡易說明這樣的寫法是為了達到什麽目的


* 可能是暫時性的寫法，以後需要回來重新寫過
    * `app/graphql/mutations/update_course.rb` 中有個章節和單元排序的問題就有寫註解



## 實作方式說明


### mutation class 繼承

* mutation 可以繼承這兩種

    * `GraphQL::Schema::Mutation`
    * `GraphQL::Schema::RelayClassicMutation` - 傳入的參數需要放在 `input` 中，目前 `graphql` gem 預設是使用這種，如果不想多包一層 `input` 可以使用 `GraphQL::Schema::Mutation`


### update course

* `update course` 的 API 較為複雜，需要依照實際需求做出較為符合需求的 API

* `update course` 中需要同時更新課程、章節和單元的資料，目前使用的更新方式是把整個 `course` 下面所有的資料包含章節和單元當作參數傳入，server 會比對資料庫中的 `id` 進行更新，不在參數中的章節和單元會被刪除，這樣 client 不用去另外加像是 `deleted` flag 之類的去記錄章節和單元是否需要被刪除，call api 時也不用另外傳需要被刪除的章節和單元的 `id`



## 遇到的問題


* 雖然之前有在接案過程中接觸到 GraphQL 的開發，但由於是中途加入，並沒有完整導入 GraphQL 的經驗，並且當時是採用 node.js 作為後端語言，不同語言框架實作 GraphQL 架構還是有些差異，所以這次花了蠻多時間看看是不是有人會設計出不同的架構

* 以前沒有寫過的 GraphQL 相關的測試，這次也花了一些時間看看其他人怎麼測試，目前是採用直接發 request 的方式測試



## reference


* https://www.digitalocean.com/community/tutorials/how-to-set-up-a-ruby-on-rails-graphql-api
* https://graphql-ruby.org/mutations/mutation_errors
* https://graphql-ruby.org/api-doc/1.8.8/GraphQL/Relay/Mutation.html
* https://graphql-ruby.org/api-doc/1.8.8/GraphQL/Relay/Mutation.html
* https://evilmartians.com/chronicles/graphql-on-rails-1-from-zero-to-the-first-query
