Bredis::BusinessRule.new({
                           'priority' => nil,
                           'id' => 1,
                           'op' => '?',
                           'lhs' => {
                             'id' => 2,
                             'lhs' => '$product', 
                             'op' => '==', 
                             'rhs' => 'shoes'
                           }, 
                           'rhs' => {
                             'id' => 3,
                             'lhs' => '$discount', 
                             'op' => '=',
                             'rhs' => {
                               'id' => 7,
                               'lhs' =>'$fare',
                               'op' => '/',
                               'rhs' => 2}
                               }}.to_json)

Bredis::BusinessRule.new({
                           'priority' => nil,
                           'id' => 4,
                           'op' => '?',
                           'lhs' => {
                             'id' => 5,
                             'lhs' => '$product', 
                             'op' => '==', 
                             'rhs' => 'clothes'
                               }, 
                           'rhs' => {
                             'id' => 6,
                             'lhs' => '$discount', 
                             'op' => '=',
                             'rhs' => 200
                           }}.to_json)

