# lambdasNodePack
AWSラムダLayerで使うNode.jsのライブラリをパッキングしました。

# Export lambda pack
```bash
./tozip.sh
```

# Raw command
```bash
zip -r lambdasNodePack.zip nodejs/
```

# Add module
モジュールを追加する際は次のようにします。下記の例では例えばaxiosを追加する場合です。

```bash
cd lambdasNodePack/lambdasNodepack/
npm install axios
cd ../
./tozip
```
tozip.shと同じ階層に、lambdasNodePack.zipが生成されます。

Layerｎ追加する際は、package.jsonも必要です。node_modulesとpackage.jsonが含まれるディレクトリごとzipにまとめます。

また、zip後のファイル名は任意ですが、zipするファイル名は「nodejs」である必要があります。これはlambdaの仕様のためです。もし変更する場合は、AWSコンソールからpathの設定が必要になるため、特にこだわりがなければディレクトリ名を「nodejs」としておくことが無難でしょう。

次に、生成したlambdasNodePack.zipをAWSラムダのLayerに追加します。
LayerはAWSコンソールのLambda画面下部の「Layerの追加」から追加できます。

Layer追加後は、Node.jsのバージョンを忘れずに設定します。「Lambdaのラインタイム」「Layerのランタイム」の両方を一致させます。

# PoC
lambdasNodePackが有効であるかは次のコードを実行させることで検証できます。
次のコードをindex.jsに記述して下さい。なお、Lambdaはデフォルトでは、index.jsのhandlerメソッドを最初に実行する設定になっているため、最初に呼び出すファイル名は「index.js」としておくことが一般的です。

コードをindex.jsに記述したら、デプロイを行い「テスト」ボタンを押して実行します。handlerメソッドにテストイベントがリクエストされ、コードが実行されます。

```node.js
const axios = require("axios");

exports.handler = async (event) => {
    const apiUrl = 'https://jsonplaceholder.typicode.com/posts/1';
    const response = await axios.get(apiUrl);
    console.log(response.data);
    
    return {
        statusCode: 200,
        body: JSON.stringify(response.data)
    };
};
```

テストイベントの例
```json
{
  "version": "0",
  "id": "test-event-001",
  "detail-type": "Test Event",
  "source": "custom.test",
  "account": "123456789012",
  "time": "2022-05-01T00:00:00Z",
  "region": "ap-northeast-1",
  "resources": [],
  "detail": {}
}
```
正常に動作した場合、次のようなレスポンスが得られます。
```text
Response
{
  "statusCode": 200,
  "body": "{\"userId\":1,\"id\":1,\"title\":\"sunt aut facere repellat provident occaecati excepturi optio reprehenderit\",\"body\":\"quia et suscipit\\nsuscipit recusandae consequuntur expedita et cum\\nreprehenderit molestiae ut ut quas totam\\nnostrum rerum est autem sunt rem eveniet architecto\"}"
}
```

# VPC settings
Lambdaから外部のwebAPIにリクエストを送信するだけの場合、デフォルトではVPCやセキュリティグループの設定は不要です。ただし、VPC内のリソースにアクセスする場合は必要になります。

# Env settings
Lambdaでは「設定」のタブから環境変数が設定できますが、上記のPoCを利用するだけであれば不要です。Lambdaはデフォルトで「/opt/nodejs/node_modules」のpathが設定されておるため設定が不要です。もう少し具体的に説明すると、lambdasNodePackレイヤーが追加された場合Lambda上では次のようなディレクトリ構成になるとイメージしてもらえるとよいでしょう。

```text
/opt
├── nodejs
│   ├── node_modules
│   ├── package.json
│   ├── package-lock.json
│   └── xxxx
├── python
│   ├── xxxx
```
