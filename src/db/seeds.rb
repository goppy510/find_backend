# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Industry.create([
  { name: 'セールスプロモーション'},
  { name: '広告・Web制作・マーケティング支援'},
  { name: 'Webサービス'},
  { name: 'メーカー'},
  { name: '店舗運営'},
  { name: '不動産'},
  { name: '人材'},
  { name: 'その他'}
])

EmployeeCount.create([
  { name: '1〜29名', range: 'xs' },
  { name: '30〜49名', range: 'ss' },
  { name: '50〜99名', range: 's' },
  { name: '100〜299名', range: 'm' },
  { name: '300〜599名', range: 'l' },
  { name: '600〜999名', range: 'xl' },
  { name: '1000名以上', range: 'xxl' }
])

Position.create([
  { name: '経営者/役員' },
  { name: '部長' },
  { name: '課長/マネージャー' },
  { name: '主任' },
  { name: '一般社員' },
  { name: '代理店/クライアント提案' },
  { name: 'その他/個人事業主'}
])

BusinessModel.create([
  { name: 'BtoB' },
  { name: 'BtoC' },
  { name: 'その他' }
])
