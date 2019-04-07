class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  
  has_many :microposts
  has_many :relationships
  #多対多の図の右半分にいる「自分"が"フォローしているUser」への参照
  #has_many :relationshipsはRelationshipモデルへの参照。Userから見た中間テーブルとの関係。
  has_many :followings, through: :relationships, source: :follow
  #has_many :followingsという関係を新しく命名して「フォローしているUser達」を表現。through: :relationships記述により、has_many :relationshipsの結果を中間テーブルとして指定している.
  #更に、中間テーブルのカラムの中でどれを参照先のidとすべきかをsource: :followで選択している。
  #結果として、user.followingsというメソッドを用いると、userが中間テーブルrelationshipsを取得し、その１つ１つのrelationshipのfollow_idから「自分"が"フォローしているUser達」を取得する」処理が可能になる。
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
  
  def follow(other_user)
    unless self == other_user
    #上記の記述により、フォローしようとしているother_userが自分自身ではないかを検証している。
      self.relationships.find_or_create_by(follow_id: other_user.id)
      #見つかればRelationを返し、見つからなければself.relationships.find_or_create_by(follow_id: other_user.id)としてフォロー関係を保存(create=build+save)することができる。
    end
  end
  
  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
    #relationshipが存在すればdestroyする。if文はこんな感じ。
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
    #self.followingsによりUser達を取得し、include?でother_userが含まれてないか確認している。含まれていたらtrue、いなければfalse
  end
end
