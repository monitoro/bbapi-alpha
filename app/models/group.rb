# -*- coding: utf-8 -*-
class Group < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  has_many :group_members,    dependent: :destroy
  has_many :members, through: :group_members
  has_many :monthly_balances, dependent: :destroy
  has_many :bookkeepings,     dependent: :destroy
  has_many :account_titles,   dependent: :destroy

  # 유효성 검증 => owner_id 는 필수항목임
  validates_presence_of :owner_id
  # 유효성 검증 => 각자의 scope 내에서 그룹명(name)은 유일해야 함.
  validates_uniqueness_of :name, :scope => [:owner_id]

  # 계정항목만듬
  after_create :create_account_titles

  # 이미 등록된 유저인 경우 true 값을 반환함.
  def added?(user)
    group_members.where( member_id: user.id ).first.present?
  end

  # 멤버유저 등록 (중복 유저인 경우 예외를 발생한다.)
  def add!(user)
    group_members.create!(member_id: user.id) unless added?(user)
  end

  # 멤버유저 삭제 (삭제시 문제가 발생하면 예외를 발생한다.)
  def remove!(user)
    group_members.find_by(member_id: user.id).destroy!
  end

  def create_account_titles
    # 비용 추가
    outlay_category = AccountCategory.find(AccountCategory::ACCOUNT_CATEGORY_OUTLAY)
    ["식비", "교통비", "주거,통신", "생활용품", "경조사비", "지식,문화", "의복,미용", "의료,건강", "여가,유흥", "세금,이자", "기타비용"].each do |outlay|
      AccountTitle.create({ group:self, account_category:outlay_category, title:outlay })
    end

    # 수입 추가
    income_category = AccountCategory.find(AccountCategory::ACCOUNT_CATEGORY_INCOME)
    ["회비", "월급", "상여금", "펀드,주식", "기타수익"].each do |outlay|
      AccountTitle.create({ group:self, account_category:income_category, title:outlay })
    end
  end

end
